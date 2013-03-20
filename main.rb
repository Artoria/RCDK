require './k'
require './win32'

Headers.cstdio = 1
Headers.cstdlib = 1
Win32.ClsName = "Hello"
Win32.Title = "World"

args = :h, :m, :w, :l

Win32.WM_CREATE *args do
   CreateWindowEx(0, "Button", "click me", :"WS_CHILD|WS_VISIBLE", 0, 0, 100, 20, :h, :"(HMENU)100", 0, 0)
end

Win32.WM_COMMAND *args do
   scope "if(w == 100)" do
      MessageBox(0, "Hello", 0, 16)
   end
end

