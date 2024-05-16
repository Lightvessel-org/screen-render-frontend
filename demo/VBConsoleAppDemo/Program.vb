Imports System
Imports System.Runtime.InteropServices
Imports System.Text.RegularExpressions
Imports VBConsoleAppDemo.LedApi


Public Class LedApi
    Private Property hModule As Long
    Private Const LedFrontendDLL = "LedFrontend.dll"

    Private Declare Function LoadLibrary Lib "kernel32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As Long
    Private Declare Function GetProcAddress Lib "kernel32" (ByVal hModule As Long, ByVal lpProcName As String) As Long
    Private Declare Function FreeLibrary Lib "kernel32" (ByVal hModule As Long) As Long

    ' Native Bindings
    Public Delegate Function RunPrecioledDelegate() As Integer
    Public RunPrecioled As RunPrecioledDelegate

    Public Delegate Function CreateImageDelegate() As Integer
    Public CreateImage As CreateImageDelegate

    Public Delegate Function DeleteImageDelegate(id As Integer) As Integer
    Public DeleteImage As DeleteImageDelegate

    Public Sub New()
        hModule = LedApi.LoadLibrary(LedFrontendDLL)
        If hModule = 0 Then
            Throw New System.Exception("Unable to load " & LedFrontendDLL)
            Exit Sub
        End If

        RunPrecioled = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("run_precioled")), GetType(RunPrecioledDelegate)), RunPrecioledDelegate)
        CreateImage = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("create_image")), GetType(CreateImageDelegate)), CreateImageDelegate)
        DeleteImage = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("delete_image")), GetType(DeleteImageDelegate)), DeleteImageDelegate)

    End Sub

    Private Function Fetch(ByVal name As String) As Long
        Dim pFunc As Long
        pFunc = GetProcAddress(hModule, name)
        If pFunc = 0 Then
            Throw New System.Exception("Unable to find function" & name & " in DLL " & LedFrontendDLL)
            FreeLibrary(hModule)
            Exit Function
        End If
        Return pFunc
    End Function

    Public Function Free() As Long
        Return FreeLibrary(hModule)
    End Function

End Class

Module Program
    Sub Main(args As String())

        Dim api As New LedApi()

        Dim result As Integer
        result = api.RunPrecioled()
        Console.WriteLine("Started Frontend: " & result)
        Console.ReadLine()
        api.CreateImage()
        api.DeleteImage(123)
        api.CreateImage()
        Console.ReadLine()
        api.CreateImage()
        Console.ReadLine()
    End Sub
End Module
