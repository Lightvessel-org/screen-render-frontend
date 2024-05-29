Imports System
Imports System.Runtime.InteropServices
Imports System.Text.RegularExpressions
Imports VBConsoleAppDemo.LedApi


Public Class LedApi
    Private Property hModule As Long
    Private Const LedFrontendDLL = "LedFrontend.dll"

    <DllImport("kernel32.dll", SetLastError:=True, CharSet:=CharSet.Unicode)>
    Private Shared Function LoadLibrary(ByVal lpLibFileName As String) As Long
    End Function

    Private Declare Function GetProcAddress Lib "kernel32" (ByVal hModule As Long, ByVal lpProcName As String) As Long
    Private Declare Function FreeLibrary Lib "kernel32" (ByVal hModule As Long) As Long

    ' Native Bindings
    Public Delegate Function RunPrecioledDelegate() As Integer
    Public RunPrecioled As RunPrecioledDelegate

    Public Delegate Function CreateImageDelegate(file As String, posX As Single, posY As Single, scale As Single) As Integer
    Public CreateImage As CreateImageDelegate

    Public Delegate Function DeleteImageDelegate(id As Integer) As Integer
    Public DeleteImage As DeleteImageDelegate

    Public Delegate Function MoveDelegate(id As Integer, posX As Single, posY As Single) As Integer
    Public Move As MoveDelegate

    Public Sub New()
        hModule = LedApi.LoadLibrary(LedFrontendDLL)
        If hModule = 0 Then
            Throw New System.Exception("Unable to load " & LedFrontendDLL)
            Exit Sub
        End If

        RunPrecioled = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("run_precioled")), GetType(RunPrecioledDelegate)),  RunPrecioledDelegate)
        CreateImage  = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("create_image")),  GetType(CreateImageDelegate)),   CreateImageDelegate)
        DeleteImage  = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("delete_image")),  GetType(DeleteImageDelegate)),   DeleteImageDelegate)
        Move         = CType(Marshal.GetDelegateForFunctionPointer(New IntPtr(Fetch("move")),          GetType(MoveDelegate)),          MoveDelegate)

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
        Dim imageId As Integer
        imageId = api.CreateImage("assets/golden_ball.png", 200.0, 200.0, 0.2) 'Path relativo al exe
        Console.WriteLine("Imagen creada con ID=" & imageId)
        Console.ReadLine()
        api.Move(imageId, 0.0, 0.0)
        Console.ReadLine()
        api.Move(imageId, 400.0, 100.0)
        Console.ReadLine()
    End Sub
End Module
