unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, PathTracer, StdCtrls, ExtCtrls, ImgList, CommCtrl,
  Menus, AppEvnts, Utils;

type
  TMainForm = class(TForm)
    Img: TImage;
    Toolbar: TToolBar;
    SceneSelectionBtn: TToolButton;
    SepBtn2: TToolButton;
    PlayPauseBtn: TToolButton;
    StopBtn: TToolButton;
    SepBtn1: TToolButton;
    SettingsBtn: TToolButton;
    ToolImages: TImageList;
    SceneMenu: TPopupMenu;
    SettingsMenu: TPopupMenu;
    Resolution1: TMenuItem;
    N32x321: TMenuItem;
    N64641: TMenuItem;
    N1281281: TMenuItem;
    N2562561: TMenuItem;
    N5125121: TMenuItem;
    StatusBar: TStatusBar;
    SaveDlg: TSaveDialog;
    Samplestep1: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N51: TMenuItem;
    N101: TMenuItem;
    N201: TMenuItem;
    N501: TMenuItem;
    N1001: TMenuItem;
    ProgIcon: TImage;
    N1: TMenuItem;
    hreadcount1: TMenuItem;
    N12: TMenuItem;
    N22: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N61: TMenuItem;
    N81: TMenuItem;
    N161: TMenuItem;
    N2001: TMenuItem;
    N5001: TMenuItem;
    RenderTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SceneSelectionBtnClick(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure N32x321Click(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure PlayPauseBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RenderTimerTimer(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    procedure GetIcon(const Name: String);
    procedure LoadAllScenes;
    procedure SceneSelection(Sender: TObject);
  end;

var
  MainForm: TMainForm;
  Scenes: array of String;
  Tracer: TPathTracer;
  Bitmap: TBitmap;
  Running: Boolean = False;
  Resolution: Longword = 128;
  SampleStep: Longword = 5;
  ThreadCount: Longword = 4;
  F, Q: Int64;

implementation

{$R *.dfm}

{ Loads icons from the \Icons folder, dynamic loading is required because TImageList does not properly support alpha icons. }
procedure TMainForm.GetIcon(const Name: String);
Var
 Icon: TIcon;
begin
 Icon := TIcon.Create;
 try
  Icon.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Icons\' + Name + '.ico');
  ToolImages.AddIcon(Icon);
 finally
  Icon.Free;
 end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 { To avoid freezing the computer we set the application's priority to lowest. }
 Windows.SetPriorityClass(GetCurrentProcess, 1);
 QueryPerformanceCounter(Q);
 Application.Icon := ProgIcon.Picture.Icon;
 DoubleBuffered := True;
 ToolImages.Handle := Imagelist_Create(32, 32, ILC_COLOR32, 0, 0); // recreates the ImageList to support 32-bit alpha icons
 GetIcon('Scene');
 GetIcon('Settings');
 GetIcon('Play');
 GetIcon('Pause');
 GetIcon('Stop');
 LoadAllScenes;
end;

{ Loads all the scenes found in the program's directory. }
procedure TMainForm.LoadAllScenes;
Var
 Rec: TSearchRec;
 M: TMenuItem;
 S: String;
begin
 { Looks for all files ending in .pts only. }
 if FindFirst('*.pts', faAnyFile, Rec) = 0 then
  begin
   repeat
    { If one is found, create a menu entry for it. }
    S := ExtractFileName(Rec.Name);
    S := Copy(S, 1, Length(S) - 4);

    M := TMenuItem.Create(SceneMenu);
    M.Caption := S;
    M.OnClick := SceneSelection;
    M.Tag := Length(Scenes);
    SceneMenu.Items.Add(M);
    SetLength(Scenes, Length(Scenes) + 1);
    Scenes[High(Scenes)] := S;
   until FindNext(Rec) <> 0;
   FindClose(Rec);
  end;
end;

procedure TMainForm.SceneSelection(Sender: TObject);
begin
 { Kill the tracer if it's currently running, then create it again with the new settings. }
 if Running then Tracer.Free;
 Tracer := TPathTracer.Create(False, ThreadCount, 1024, SampleStep, Resolution, Resolution, ExtractFilePath(ParamStr(0)) + Scenes[TMenuItem(Sender).Tag] + '.pts');
 Running := True;
end;

procedure TMainForm.SceneSelectionBtnClick(Sender: TObject);
Var
 P: TPoint;
begin
 { Purely aesthetic, opens the popup even if the button isn't clicked on the dropdown arrow. }
 GetCursorPos(P);
 SceneMenu.Popup(P.X, P.Y);
end;

procedure TMainForm.SettingsBtnClick(Sender: TObject);
Var
 P: TPoint;
begin
 { Purely aesthetic, opens the popup even if the button isn't clicked on the dropdown arrow. }
 GetCursorPos(P);
 SettingsMenu.Popup(P.X, P.Y);
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
 { First suspend the tracer, otherwise loading the dialog form may take forever. }
 Tracer.Suspend;

 { If the user wants to save the result... }
 if SaveDlg.Execute then
  begin
   { Acquire the latest bitmap, and save it to the file. }
   Tracer.Acquire(Bitmap);
   Bitmap.SaveToFile(SaveDlg.FileName);
  end;

 { Kill the tracer, and end the process. }
 Tracer.Free;
 Running := False;
end;

procedure TMainForm.PlayPauseBtnClick(Sender: TObject);
begin
 { Toggles between suspend/resume. }
 if Tracer.Suspended then Tracer.Resume else Tracer.Suspend;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 { Makes sure the tracer dies before the application does, to avoid threading issues. }
 if Running then Tracer.Free;
end;

{ We can reuse the same bitmap throughout the entire application. }
procedure TMainForm.RenderTimerTimer(Sender: TObject);
Var
 Q2: Int64;
begin
 { Enables or disables buttons depending on whether the program is actively working. }
 SettingsBtn.Enabled := not Running;
 PlayPauseBtn.Enabled := Running;
 StopBtn.Enabled := Running;
 if not Running then PlayPauseBtn.ImageIndex := 2 else
  if Tracer.Suspended then PlayPauseBtn.ImageIndex := 2 else PlayPauseBtn.ImageIndex := 3;

 { Introduce a 1/60 sleep to avoid spending most CPU time in this idle method. }
 QueryPerformanceCounter(Q2);
 if (Q2 - Q) / F < 1 / 60 then Exit else Q := Q2;
 if not Running then
  begin
   { If the application's not working, draw a black image and update the statusbar accordingly. }
   BitBlt(Img.Canvas.Handle, 0, 0, Img.Width, Img.Height, 0, 0, 0, BLACKNESS);
   Img.Invalidate;
   StatusBar.SimpleText := 'Idle, please choose a scene.';
  end
 else
  begin
   { If it is running, acquire the bitmap, stretch it over the image's canvas, and show the current status in the statusbar
     (taking into account whether the operation is suspended or not). }
   Tracer.Acquire(Bitmap);
   Img.Canvas.StretchDraw(Img.ClientRect, Bitmap);
   if Tracer.Suspended then StatusBar.SimpleText := Format('Raytracing paused, %.1f samples processed on average so far.', [Tracer.SampleCount]) else
    StatusBar.SimpleText := Format('Raytracing in progress, %.1f samples processed on average so far.', [Tracer.SampleCount]);
  end;
end;

procedure TMainForm.N32x321Click(Sender: TObject);
begin
 { Handles all the settings menu. }
 with TMenuItem(Sender) do
  begin
   case GroupIndex of
    1: Resolution := 1 shl Tag;
    2: SampleStep := Longword(Tag);
    3: ThreadCount := Longword(Tag);
   end;

   Checked := True;
  end;
end;

initialization
 Bitmap := TBitmap.Create;
 QueryPerformanceFrequency(F);

finalization
 Bitmap.Free;

end.
