using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;

namespace MouseTestMover;

public partial class MainWindow : Window
{
    private const int CursorOffsetPixels = 3;
    private readonly DispatcherTimer _displayTimer;
    private DateTime _nextMoveAt;
    private TimeSpan _selectedInterval = TimeSpan.FromSeconds(30);
    private long _moveCount;
    private bool _isRunning;

    public MainWindow()
    {
        InitializeComponent();
        _displayTimer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(250) };
        _displayTimer.Tick += DisplayTimer_Tick;
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
        _displayTimer.Stop();
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
            if (MoveCursorBriefly()) _moveCount++;
            _nextMoveAt = DateTime.Now.Add(_selectedInterval);
        }
        UpdateDisplay();
    }

    private static bool MoveCursorBriefly()
    {
        if (!NativeMethods.GetCursorPos(out NativeMethods.POINT originalPosition)) return false;
        bool moved = NativeMethods.SetCursorPos(originalPosition.X + CursorOffsetPixels, originalPosition.Y);
        bool restored = NativeMethods.SetCursorPos(originalPosition.X, originalPosition.Y);
        return moved && restored;
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
    }

    private void Window_Closing(object? sender, System.ComponentModel.CancelEventArgs e) => Stop();
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
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static extern bool SetCursorPos(int x, int y);

    [StructLayout(LayoutKind.Sequential)]
    internal struct POINT { internal int X; internal int Y; }
}
