Win32      = KStruct.new
Classes    = KStruct.new
Headers    = KStruct.new
require 'erb'
x = Win32.WM_PAINT

def new_class
  KStruct.new
end

def x.beginpaint(hwnd, hdc, &block)
  define "HDC", hdc
  define "PAINTSTRUCT", :psPaint
  assign  hdc, :"BeginPaint(#{t hwnd}, &psPaint)"
  if block
    yield
    endpaint hwnd
  end
end

def x.endpaint(hwnd)
   EndPaint hwnd, :"&psPaint"
end


END {
Headers.funcs.each{|k, v|
  puts "#include <#{k}>"
}

Classes.funcs.each{|k, v|
  puts "struct #{k}{"

  v.value.funcs.each{|k, v|
    puts v;
  }

  puts "};"
}

x = ERB.new %{
  #include <cstdio>
  #include <windows.h>
  LPCTSTR ClsName = <%=Win32.ClsName%>;
  LPCTSTR WndName = <%=Win32.Title%>;

  LRESULT CALLBACK WndProcedure(HWND hWnd, UINT uMsg,
			      WPARAM wParam, LPARAM lParam);

  INT WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
               LPSTR lpCmdLine, int nCmdShow)
  {
	MSG        Msg;
	HWND       hWnd;
	WNDCLASSEX WndClsEx;

	// Create the application window
	WndClsEx.cbSize        = sizeof(WNDCLASSEX);
	WndClsEx.style         = CS_HREDRAW | CS_VREDRAW;
	WndClsEx.lpfnWndProc   = WndProcedure;
	WndClsEx.cbClsExtra    = 0;
	WndClsEx.cbWndExtra    = 0;
	WndClsEx.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
	WndClsEx.hCursor       = LoadCursor(NULL, IDC_ARROW);
	WndClsEx.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
	WndClsEx.lpszMenuName  = NULL;
	WndClsEx.lpszClassName = ClsName;
	WndClsEx.hInstance     = hInstance;
	WndClsEx.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);

	// Register the application
	RegisterClassEx(&WndClsEx);

	// Create the window object
	hWnd = CreateWindow(ClsName,
			  WndName,
			  WS_OVERLAPPEDWINDOW,
			  CW_USEDEFAULT,
			  CW_USEDEFAULT,
			  CW_USEDEFAULT,
			  CW_USEDEFAULT,
			  NULL,
			  NULL,
			  hInstance,
			  NULL);
	
	// Find out if the window was created
	if( !hWnd ) // If the window was not created,
		return 0; // stop the application

	// Display the window to the user
	ShowWindow(hWnd, SW_SHOWNORMAL);
	UpdateWindow(hWnd);

	// Decode and treat the messages
	// as long as the application is running
	while( GetMessage(&Msg, NULL, 0, 0) )
	{
             TranslateMessage(&Msg);
             DispatchMessage(&Msg);
	}

	return Msg.wParam;
  }

   LRESULT CALLBACK WndProcedure(HWND hWnd, UINT Msg,  WPARAM wParam, LPARAM lParam)
   {
    switch(Msg)
    {
    // If the user wants to close the application
    case WM_DESTROY:
        // then close it
        PostQuitMessage(WM_QUIT);
        break;

    <% for k,v in Win32.funcs %>
    <%   if k.to_s[/WM_/] %>
       case <%=k%>:
          LRESULT message_<%=k%>(HWND, UINT, WPARAM, LPARAM);
          return message_<%=k%>(hWnd, Msg, wParam, lParam);
    <%  end %>
    <% end %>
    default:
        // Process the left-over messages
        return DefWindowProc(hWnd, Msg, wParam, lParam);
    }
    // If something was not done, let it go
    return 0;
   } 
    <%for k,v in Win32.funcs %>
    <% if k.to_s[/WM_/] %>
          LRESULT message_<%=k%>(HWND <%=v.arguments[0]%>, UINT <%=v.arguments[1]%>,  WPARAM <%=v.arguments[2]%>, LPARAM <%=v.arguments[3]%>){
              <%=v%>
          }
     <%  end %>
    <% end %>

  }
  puts x.result(binding)
}