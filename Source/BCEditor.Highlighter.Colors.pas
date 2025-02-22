unit BCEditor.Highlighter.Colors;

interface

uses
  System.Classes, Vcl.Graphics, BCEditor.Highlighter.Info;

type
  TBCEditorHighlighterElement = record
    Background: TColor;
    Foreground: TColor;
    Name: string;
    Style: TFontStyles;
  end;
  PBCEditorHighlighterElement = ^TBCEditorHighlighterElement;

  TBCEditorHighlighterColors = class(TObject)
  strict private
    FFileName: string;
    FInfo: TBCEditorHighlighterInfo;
    FElements: TList;
    FName: string;
    FOwner: TObject;
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function GetElement(const Name: string): PBCEditorHighlighterElement;
    procedure Clear;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStream(AStream: TStream);
    property FileName: string read FFileName write FFileName;
    property Info: TBCEditorHighlighterInfo read FInfo write FInfo;
    property Name: string read FName write FName;
    property Styles: TList read FElements write FElements;
  end;

implementation

uses
  System.SysUtils, BCEditor.Editor.Base, BCEditor.Highlighter, BCEditor.Highlighter.JSONImporter, System.IOUtils;

{ TBCEditorHighlighterColors }

constructor TBCEditorHighlighterColors.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FElements := TList.Create;
  FInfo := TBCEditorHighlighterInfo.Create;
end;

destructor TBCEditorHighlighterColors.Destroy;
begin
  Clear;
  FElements.Free;
  FInfo.Free;

  inherited;
end;

procedure TBCEditorHighlighterColors.Clear;
var
  i: Integer;
begin
  for i := FElements.Count - 1 downto 0 do
    Dispose(PBCEditorHighlighterElement(FElements.Items[i]));
  FElements.Clear;
end;

function TBCEditorHighlighterColors.GetElement(const Name: string): PBCEditorHighlighterElement;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FElements.Count - 1 do
    if PBCEditorHighlighterElement(FElements.Items[i])^.Name = Name then
    begin
      Result := FElements.Items[i];
      Break;
    end;
end;

procedure TBCEditorHighlighterColors.LoadFromFile(const AFileName: string);
var
  LStream: TStream;
  LHighlighter: TBCEditorHighlighter;
  LEditor: TBCBaseEditor;
begin
  FFileName := AFileName;
  FName := TPath.GetFileNameWithoutExtension(AFileName);

  LHighlighter := TBCEditorHighlighter(FOwner);
  LEditor := LHighlighter.Editor as TBCBaseEditor;
  LStream := LEditor.CreateFileStream(LEditor.GetColorsFileName(AFileName));
  try
    LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

procedure TBCEditorHighlighterColors.LoadFromStream(AStream: TStream);
var
  LHighlighter: TBCEditorHighlighter;
begin
  TBCEditorHighlighter(FOwner).Loading := True;
  LHighlighter := TBCEditorHighlighter(FOwner);
  with TBCEditorHighlighterJSONImporter.Create(LHighlighter) do
  try
    ImportColorsFromStream(AStream);
  finally
    Free;
  end;
  LHighlighter.UpdateColors;
  TBCEditorHighlighter(FOwner).Loading := False;
end;

end.
