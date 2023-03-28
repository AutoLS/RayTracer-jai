#import "Windows_Utf8";

cls_1 :: ()
{
    h_stdout: HANDLE;

    h_stdout = GetStdHandle(STD_OUTPUT_HANDLE);

    mode: DWORD = 0;
    if !GetConsoleMode(h_stdout, *mode) return;

    original_mode := mode;
    mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;

    if !SetConsoleMode(h_stdout, mode) return;

    written: DWORD = 0;
    sequence: string = "\x1b[2J";
    sequence_utf16, success, len := utf8_to_wide(sequence);

    if !WriteConsoleW(h_stdout, sequence_utf16, cast(DWORD)len, *written, null)
    {
        SetConsoleMode(h_stdout, original_mode);
        return;
    }

    SetConsoleMode(h_stdout, original_mode);
}

cls_2 :: ()
{
    h_stdout: HANDLE;

    h_stdout = GetStdHandle(STD_OUTPUT_HANDLE);

    csbi: CONSOLE_SCREEN_BUFFER_INFO;
    scroll_rect: SMALL_RECT;
    scroll_target: COORD;
    fill: CHAR_INFO;

    if !GetConsoleScreenBufferInfo(h_stdout, *csbi)
    {
        return;
    }

    scroll_rect.left = 0;
    scroll_rect.top = 0;
    scroll_rect.right = csbi.dwSize.x;
    scroll_rect.bottom = csbi.dwSize.y;

    // Scroll it upwards off the top of the buffer with a magnitude of the entire height.
    scroll_target.x = 0;
    scroll_target.y = cast(s16)(0 - csbi.dwSize.y);

    // Fill with empty spaces with the buffer's default text attribute.
    // 32 is Ascii value of space
    fill.Char.UnicodeChar = 32;
    fill.Attributes = csbi.wAttributes;

    ScrollConsoleScreenBufferW(h_stdout, *scroll_rect, null, scroll_target, *fill);

    csbi.dwCursorPosition.x = 0;
    csbi.dwCursorPosition.y = 0;

    SetConsoleCursorPosition(h_stdout, csbi.dwCursorPosition);
}

clear_console_at_position :: (position: COORD)
{
    csbi: CONSOLE_SCREEN_BUFFER_INFO;
    h_stdout := GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(h_stdout, *csbi);
    written: DWORD; 
    cells: DWORD = xx (csbi.dwSize.x * csbi.dwSize.y);
    fill: u16 = 32; //* Space character
    FillConsoleOutputCharacterW(h_stdout, fill, cells, position, *written);
    FillConsoleOutputAttribute(h_stdout, csbi.wAttributes, cells, position, *written);
    SetConsoleCursorPosition(h_stdout, .{});
}