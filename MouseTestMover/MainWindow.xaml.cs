using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;

namespace MouseTestMover;

public partial class MainWindow : Window
{
    private const int CursorOffsetPixels = 15;
    private readonly DispatcherTimer _displayTimer;
    private DateTime _nextMoveAt;
    private TimeSpan _selectedInterval = TimeSpan.FromSeconds(30);
    private long _moveCount;
    private bool _isRunning;

    public MainWindow()
    {
        InitializeComponent();
        MovementDescriptionTextBlock.Text = $"Desplaza {CursorOffsetPixels} píxeles y regresa.";
        _displayTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
        _displayTimer.Tick += DisplayTimer_Tick;
        _displayTimer.Start();
        UpdateDisplay();
    }

    private void StartStopButton_Click(object sender, RoutedEventArgs e)
    {
        if (_isRunning) Stop(); else Start();
    }

    private void StopNowButton_Click(object sender, RoutedEventArgs e) => Stop();

    private void IntervalComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (IntervalComboBox.SelectedItem is ComboBoxItem { Tag: string seconds } && int.TryParse(seconds, out int value))
        {
            _selectedInterval = TimeSpan.FromSeconds(value);
            if (_isRunning) _nextMoveAt = DateTime.Now.Add(_selectedInterval);
            if (StatusTextBlock is not null) UpdateDisplay();
        }
    }

    private void Start()
    {
        _isRunning = true;
        _nextMoveAt = DateTime.Now.Add(_selectedInterval);
        NativeMethods.SetThreadExecutionState(
            NativeMethods.ExecutionState.Continuous | NativeMethods.ExecutionState.DisplayRequired);
        _displayTimer.Start();
        IntervalComboBox.IsEnabled = false;
        StartStopButton.Content = "Detener";
        StopNowButton.IsEnabled = true;
        UpdateDisplay();
    }

    private void Stop()
    {
        _isRunning = false;
        NativeMethods.SetThreadExecutionState(NativeMethods.ExecutionState.Continuous);
        IntervalComboBox.IsEnabled = true;
        StartStopButton.Content = "Iniciar";
        StopNowButton.IsEnabled = false;
        UpdateDisplay();
    }

    private void DisplayTimer_Tick(object? sender, EventArgs e)
    {
        if (_isRunning && DateTime.Now >= _nextMoveAt)
        {
            if (MoveCursorBriefly())
            {
                _moveCount++;
                MovementResultTextBlock.Text = "Último intento: movimiento enviado a Windows.";
            }
            else
            {
                MovementResultTextBlock.Text = "Último intento: Windows no aceptó el movimiento completo.";
            }
            _nextMoveAt = DateTime.Now.Add(_selectedInterval);
        }
        UpdateDisplay();
    }

    private static bool MoveCursorBriefly()
    {
        if (!NativeMethods.GetCursorPos(out NativeMethods.POINT originalPosition)) return false;
        int left = NativeMethods.GetSystemMetrics(76); // SM_XVIRTUALSCREEN
        int top = NativeMethods.GetSystemMetrics(77); // SM_YVIRTUALSCREEN
        int width = NativeMethods.GetSystemMetrics(78); // SM_CXVIRTUALSCREEN
        int height = NativeMethods.GetSystemMetrics(79); // SM_CYVIRTUALSCREEN
        if (width <= 0 || height <= 0) return false;
        int targetX = originalPosition.X + CursorOffsetPixels;
        if (targetX >= left + width) targetX = originalPosition.X - CursorOffsetPixels;
        targetX = Math.Clamp(targetX, left, left + width - 1);

        NativeMethods.INPUT CreateMove(int x, int y) => new()
        {
            Type = 0, // INPUT_MOUSE
            Mouse = new NativeMethods.MOUSEINPUT
            {
                Dx = (int)Math.Clamp(((long)x - left) * 65536 / width + 32768 / width, 0L, 65535L),
                Dy = (int)Math.Clamp(((long)y - top) * 65536 / height + 32768 / height, 0L, 65535L),
                Flags = 0x0001 | 0x8000 | 0x4000 // MOVE | ABSOLUTE | VIRTUALDESK
            }
        };

        NativeMethods.INPUT[] inputs = [CreateMove(targetX, originalPosition.Y), CreateMove(originalPosition.X, originalPosition.Y)];
        uint sent = NativeMethods.SendInput((uint)inputs.Length, inputs, Marshal.SizeOf<NativeMethods.INPUT>());
        if (sent == 1)
        {
            // Retry the return movement if Windows accepted only the first event.
            NativeMethods.SendInput(1, [inputs[1]], Marshal.SizeOf<NativeMethods.INPUT>());
        }
        return sent == inputs.Length;
    }

    private void UpdateDisplay()
    {
        if (!_isRunning)
        {
            StatusTextBlock.Text = "Estado: detenido";
            NextMoveTextBlock.Text = "Próximo movimiento: --";
        }
        else
        {
            TimeSpan remaining = _nextMoveAt - DateTime.Now;
            if (remaining < TimeSpan.Zero) remaining = TimeSpan.Zero;
            StatusTextBlock.Text = "Estado: activo";
            NextMoveTextBlock.Text = $"Próximo movimiento: {remaining:mm\\:ss}";
        }
        MoveCountTextBlock.Text = $"Movimientos realizados: {_moveCount}";
        var lastInput = new NativeMethods.LASTINPUTINFO { Size = (uint)Marshal.SizeOf<NativeMethods.LASTINPUTINFO>() };
        IdleTimeTextBlock.Text = NativeMethods.GetLastInputInfo(ref lastInput)
            ? $"Inactividad registrada por Windows: {unchecked((uint)Environment.TickCount - lastInput.Time) / 1000} s"
            : "Inactividad registrada por Windows: no disponible";
    }

    private void Window_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        Stop();
        _displayTimer.Stop();
    }
}

internal static class NativeMethods
{
    [Flags]
    internal enum ExecutionState : uint
    {
        Continuous = 0x80000000,
        DisplayRequired = 0x00000002
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern ExecutionState SetThreadExecutionState(ExecutionState executionState);

    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool GetCursorPos(out POINT point);

    [DllImport("user32.dll", SetLastError = true)]
    internal static extern uint SendInput(uint count, [In] INPUT[] inputs, int size);

    [DllImport("user32.dll")]
    internal static extern int GetSystemMetrics(int index);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool GetLastInputInfo(ref LASTINPUTINFO info);

    [StructLayout(LayoutKind.Sequential)]
    internal struct INPUT { internal uint Type; internal MOUSEINPUT Mouse; }

    [StructLayout(LayoutKind.Sequential)]
    internal struct MOUSEINPUT
    {
        internal int Dx, Dy;
        internal uint MouseData, Flags, Time;
        internal UIntPtr ExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct LASTINPUTINFO { internal uint Size, Time; }

    [StructLayout(LayoutKind.Sequential)]
    internal struct POINT { internal int X; internal int Y; }
}
