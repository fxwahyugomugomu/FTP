unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdGlobal, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP, Vcl.FileCtrl, Vcl.ComCtrls, WinInet;

type
  TForm1 = class(TForm)
    IdFTP: TIdFTP;
    Connect: TButton;
    FileListBox1: TFileListBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Button3: TButton;
    ProgressBar1: TProgressBar;
    procedure ConnectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    path,prot: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function FtpDownloadFile(strHost, strUser, strPwd: string;
  Port: Integer; ftpDir, ftpFile, TargetFile: string; ProgressBar: TProgressBar): Boolean;

  function FmtFileSize(Size: Integer): string;
  begin
    if Size >= $F4240 then
      Result := Format('%.2f', [Size / $F4240]) + ' Mb'
    else
    if Size < 1000 then
      Result := IntToStr(Size) + ' bytes'
    else
      Result := Format('%.2f', [Size / 1000]) + ' Kb';
  end;

const
  READ_BUFFERSIZE = 4096;  // or 256, 512, ...
var
  hNet, hFTP, hFile: HINTERNET;
  buffer: array[0..READ_BUFFERSIZE - 1] of Char;
  bufsize, dwBytesRead, fileSize: DWORD;
  sRec: TWin32FindData;
  strStatus: string;
  LocalFile: file;
  bSuccess: Boolean;
begin
  Result := False;

  { Open an internet session }
  hNet := InternetOpen('Program_Name', // Agent
                        INTERNET_OPEN_TYPE_PRECONFIG, // AccessType
                        nil,  // ProxyName
                        nil, // ProxyBypass
                        0); // or INTERNET_FLAG_ASYNC / INTERNET_FLAG_OFFLINE

  {
    Agent contains the name of the application or
    entity calling the Internet functions
  }


  { See if connection handle is valid }
  if hNet = nil then
  begin
    ShowMessage('Unable to get access to WinInet.Dll');
    Exit;
  end;

  { Connect to the FTP Server }
  hFTP := InternetConnect(hNet, // Handle from InternetOpen
                          PChar(strHost), // FTP server
                          port, // (INTERNET_DEFAULT_FTP_PORT),
                          PChar(StrUser), // username
                          PChar(strPwd),  // password
                          INTERNET_SERVICE_FTP, // FTP, HTTP, or Gopher?
                          0, // flag: 0 or INTERNET_FLAG_PASSIVE
                          0);// User defined number for callback

  if hFTP = nil then
  begin
    InternetCloseHandle(hNet);
    ShowMessage(Format('Host "%s" is not available',[strHost]));
    Exit;
  end;

  { Change directory }
  bSuccess := FtpSetCurrentDirectory(hFTP, PChar(ftpDir));

  if not bSuccess then
  begin
    InternetCloseHandle(hFTP);
    InternetCloseHandle(hNet);
    ShowMessage(Format('Cannot set directory to %s.',[ftpDir]));
    Exit;
  end;

  { Read size of file }
  if FtpFindFirstFile(hFTP, PChar(ftpFile), sRec, 0, 0) <> nil then
  begin
    fileSize := sRec.nFileSizeLow;
    // fileLastWritetime := sRec.lastWriteTime
  end else
  begin
    InternetCloseHandle(hFTP);
    InternetCloseHandle(hNet);
    ShowMessage(Format('Cannot find file ',[ftpFile]));
    Exit;
  end;

  { Open the file }
  hFile := FtpOpenFile(hFTP, // Handle to the ftp session
                       PChar(ftpFile), // filename
                       GENERIC_READ, // dwAccess
                       FTP_TRANSFER_TYPE_BINARY, // dwFlags
                       0); // This is the context used for callbacks.

  if hFile = nil then
  begin
    InternetCloseHandle(hFTP);
    InternetCloseHandle(hNet);
    Exit;
  end;

  { Create a new local file }
  AssignFile(LocalFile, TargetFile);
  {$i-}
  Rewrite(LocalFile, 1);
  {$i+}

  if IOResult <> 0 then
  begin
    InternetCloseHandle(hFile);
    InternetCloseHandle(hFTP);
    InternetCloseHandle(hNet);
    Exit;
  end;

  dwBytesRead := 0;
  bufsize := READ_BUFFERSIZE;

  while (bufsize > 0) do
  begin
    Application.ProcessMessages;

    if not InternetReadFile(hFile,
                            @buffer, // address of a buffer that receives the data
                            READ_BUFFERSIZE, // number of bytes to read from the file
                            bufsize) then Break; // receives the actual number of bytes read

    if (bufsize > 0) and (bufsize <= READ_BUFFERSIZE) then
      BlockWrite(LocalFile, buffer, bufsize);
    dwBytesRead := dwBytesRead + bufsize;

    { Show Progress }
    ProgressBar.Position := Round(dwBytesRead * 100 / fileSize);
    Form1.Label1.Caption := Format('%s of %s / %d %%',[FmtFileSize(dwBytesRead),FmtFileSize(fileSize) ,ProgressBar.Position]);
  end;

  CloseFile(LocalFile);

  InternetCloseHandle(hFile);
  InternetCloseHandle(hFTP);
  InternetCloseHandle(hNet);
  Result := True;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    try
       if IdFTP.Connected then
       begin
           IdFTP.Disconnect;

           FileListBox1.Clear;
//           btnConnect.Enabled := True;
//           btnDisconnect.Enabled := False;
//           btnDownload.Enabled := False;
       end;
    except
        on E:Exception do
        begin
          MessageDlg('connection error!', mtError, [mbOK], 0);
//          btnConnect.Enabled := false;
//          btnDisconnect.Enabled := true;
//          btnDownload.Enabled := true;
        end;
    end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
IdFTP.Get(Edit1.Text,'D:\SHARED\a\apa.iso');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
FtpDownloadFile('10.0.1.28','username','password',21,'',Edit1.Text,'D:\SHARED\a\apa.iso',0/100) ;
//IdFTP.Get('xyz.html','baseball2.html');
end;

procedure TForm1.ConnectClick(Sender: TObject);
begin
    try
       if not IdFTP.Connected then
       begin
           IdFTP.Host := '10.0.1.28';
           IdFTP.Username := 'gomu';
           IdFTP.Password := 'Satu';
           IdFTP.Port := 21;
           IdFTP.Connect;

           IdFTP.List(FileListBox1.Items, '', false);

          // btnConnect.Enabled := False;
         //  btnDisconnect.Enabled := True;
         //  btnDownload.Enabled := True;

       end;
    except
         on E:Exception do
         begin
             MessageDlg('connection error!', mtError, [mbOK], 0);
         //    btnConnect.Enabled := true;
         //    btnDisconnect.Enabled := false;
         //    btnDownload.Enabled := false;
         end;
    end;
end;


procedure TForm1.FileListBox1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FileListBox1.Items.Count -1 do
  try
    if FileListBox1.Selected[i] then
    begin
           // ShowMessage(FileListBox1.Items[i]);
            path:=prot+FileListBox1.Items[i];
            Label1.Caption:= path;
            Edit1.Text:=FileListBox1.Items[i];


    end;
  finally

  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
prot := 'ftp://10.0.1.28/';
Label1.Caption:='';
     FileListBox1.Clear;
end;

end.
