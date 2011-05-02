unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Synaser,
  StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnSend: TButton;
    BtnDump: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LineToSend: TEdit;
    Label1: TLabel;
    endaddr: TEdit;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    StartAddr: TEdit;
    Memo1: TMemo;
    procedure BtnSendClick(Sender: TObject);
    procedure BtnDumpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StartAddrChange(Sender: TObject);
  private
    { private declarations }
    fser:TBlockSerial;
    function espera(que: string):boolean;
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fser.free;
end;

procedure TForm1.FormShow(Sender: TObject);
var portname:String;
begin
  portname:=Application.GetOptionValue('port');
  if portname='' then
    portname:='/dev/ttyUSB0';
  fser:=TBlockSerial.create;
  fser.LinuxLock:=false;
  fser.connect(portname);
  if fser.lasterror<>0 then
  begin
    memo1.lines.add('Error opening '+portname+': '+fser.LastErrorDesc);
    exit;
  end;
  fser.Config(115200,8,'N',SB1,false,false);
  if fser.lasterror<>0 then
  begin
    memo1.lines.add('Error configuring '+portname+': '+fser.LastErrorDesc);
    exit;
  end;
  BtnSend.Enabled:=true;
  BtnDump.Enabled:=true;

end;

procedure TForm1.StartAddrChange(Sender: TObject);
begin

end;

procedure TForm1.BtnSendClick(Sender: TObject);
var c:byte;
    s:string;
begin
  fser.SendString(LineToSend.text+chr(13));
  s:='';
  repeat
    c:=fser.RecvByte(100);
    if fser.lasterror<>ErrTimeout then s:=s+(chr(c));
  until fser.lasterror=ErrTimeout;
  memo1.lines.add(s);
  
end;

function TForm1.espera(que:string):boolean;
var c:byte;
    s:string;
begin
  s:='';
  repeat
    c:=fser.RecvByte(100);
    if fser.lasterror<>ErrTimeout then
    begin
     s:=s+(chr(c));
     //memo2.lines.add(IntToHex(c,2)+' '+chr(c));
    end;
  until fser.lasterror=ErrTimeout;
  memo1.lines.add(s);
  result:=pos(que,s)<>0;
  if not result then Memo1.lines.add('****Waiting '+que+' '+inttostr(length(que))+' '+inttostr(length(s)));
end;

procedure TForm1.BtnDumpClick(Sender: TObject);
var c,c2:byte;
    s:string;
    i,i2:int64;
    l:int64;
    f:textfile;
    m,counter:int64;
    espe:string;
    ist:integer;
    ls:integer;
begin
  i:=StrToInt64(startaddr.text);
  l:=StrToInt64(endaddr.text)-1;
  if l<i then
  begin
    MessageDlg('Error','End Address must be > Start Address', mtError, [mbOk],0);
    exit;
  end;
  if not SaveDialog1.Execute then exit;
  assignfile(f,SaveDialog1.Filename);
  rewrite(f);
  ProgressBar1.Max:=(l-i+1) div 16;
  ProgressBar1.Position:=0;

  while i<l do
  begin
    fser.SendString('r');
    fser.RecvTerminated(500,{'Enter the Start Address to Read....0x'} '0x');
    fser.SendString(inttohex(i,8)+chr(13));
    fser.RecvTerminated(500,{'Data Length is (1) 4 Bytes (2) 2 Bytes (3) 1 Byte...'} '...');
    fser.SendString('3');
    fser.RecvTerminated(500,{'Enter the Count to Read....(Maximun 10000)'} ')');
    m:=l-i+1;
    if m>10000 then
      m:=10000;
    counter:=0;
    fser.SendString(IntToStr(m)+chr(13));
    i2:=i;
    espe:='0x'+IntToHex(i2,8);
    repeat
      s:=fser.RecvTerminated(200,chr(13));
      if copy(s,1,10)=espe then
      begin
        ist:=12;
        ls:=length(s);
        while ist<ls do
        begin
          c:=ord(s[ist])-ord('0');
          if c>9 then
            c:=c+ord('0')-ord('A')+10;
          ist:=ist+1;
          c2:=ord(s[ist])-ord('0');
          if c2>9 then
            c2:=c2+ord('0')-ord('A')+10;
          c:=(c shl 4) or c2;
          ist:=ist+2;
          counter:=counter+1;
          write(f,chr(c));
          //memo1.lines.add(IntToHex(c,2));
        end;
        label1.caption:=espe;
        i2:=i2+16;
        espe:='0x'+IntToHex(i2,8);
        progressbar1.StepIt;
        Application.ProcessMessages;
      end;
    until fser.LastError=ErrTimeout;
    s:=fser.RecvTerminated(200,':'); //[DANUBE Boot]:
    //memo1.lines.add(s);
    i:=i+m;
    if counter<>m then
    begin
      label1.caption:=format('error counter %d m %d',[counter,m]);
      break;
    end else
    begin
      //application.processmessages;
    end;
  end;
  closefile(f);
  ProgressBar1.Position:=0;
  label1.caption:=label1.caption+' done';
end;

{$R *.lfm}

end.

