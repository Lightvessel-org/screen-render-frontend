using System;
using System.Runtime.InteropServices;

public partial class Program
{
    [DllImport("BasicOdinGame.dll", CharSet = CharSet.Auto)]
    private static extern int version();


    public static void Main(string[] args)
    {
        //IntPtr handle = LoadLibrary("BasicOdinGame.dll");
        // IntPtr pAddressOfFunctionToCall = GetProcAddress(handle, "version");
        version();
        version();
        version();
    }
}