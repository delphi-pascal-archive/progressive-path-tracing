program PPT;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  VectorMath in 'VectorMath.pas',
  VectorTypes in 'VectorTypes.pas',
  SceneManager in 'SceneManager.pas',
  PRNG in 'PRNG.pas',
  Utils in 'Utils.pas',
  MaterialTypes in 'MaterialTypes.pas',
  PathTracer in 'PathTracer.pas',
  Camera in 'Camera.pas';

{$R *.res}
{$R WinThemes.res}

begin
  Application.Initialize;
  Application.Title := 'Progressive Path Tracing';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
