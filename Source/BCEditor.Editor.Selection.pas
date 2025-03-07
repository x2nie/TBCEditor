unit BCEditor.Editor.Selection;

interface

uses
  System.Classes, Vcl.Graphics, BCEditor.Editor.Selection.Colors, BCEditor.Types;

type
  TBCEditorSelection = class(TPersistent)
  strict private
    FActiveMode: TBCEditorSelectionMode;
    FColors: TBCEditorSelectedColor;
    FMode: TBCEditorSelectionMode;
    FOnChange: TNotifyEvent;
    FOptions: TBCEditorSelectionOptions;
    FVisible: Boolean;
    procedure DoChange;
    procedure SetActiveMode(const AValue: TBCEditorSelectionMode);
    procedure SetColors(const AValue: TBCEditorSelectedColor);
    procedure SetMode(const AValue: TBCEditorSelectionMode);
    procedure SetOnChange(AValue: TNotifyEvent);
    procedure SetOptions(AValue: TBCEditorSelectionOptions);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
    property ActiveMode: TBCEditorSelectionMode read FActiveMode write SetActiveMode stored False;
  published
    property Colors: TBCEditorSelectedColor read FColors write SetColors;
    property Mode: TBCEditorSelectionMode read FMode write SetMode default smNormal;
    property Options: TBCEditorSelectionOptions read FOptions write SetOptions default [soHighlightSimilarTerms];
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

implementation

{ TBCEditorSelection }

constructor TBCEditorSelection.Create;
begin
  inherited;

  FColors := TBCEditorSelectedColor.Create;
  FActiveMode := smNormal;
  FMode := smNormal;
  FOptions := [soHighlightSimilarTerms];
  FVisible := True;
end;

destructor TBCEditorSelection.Destroy;
begin
  FColors.Free;
  inherited Destroy;
end;

procedure TBCEditorSelection.SetOnChange(AValue: TNotifyEvent);
begin
  FOnChange := AValue;
  FColors.OnChange := FOnChange;
end;

procedure TBCEditorSelection.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TBCEditorSelection) then
  with ASource as TBCEditorSelection do
  begin
    Self.FColors.Assign(FColors);
    Self.FActiveMode := FActiveMode;
    Self.FMode := FMode;
    Self.FOptions := FOptions;
    Self.FVisible := FVisible;
    if Assigned(Self.FOnChange) then
      Self.FOnChange(Self);
  end
  else
    inherited Assign(ASource);
end;

procedure TBCEditorSelection.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TBCEditorSelection.SetColors(const AValue: TBCEditorSelectedColor);
begin
  FColors.Assign(AValue);
end;

procedure TBCEditorSelection.SetMode(const AValue: TBCEditorSelectionMode);
begin
  if FMode <> AValue then
  begin
    FMode := AValue;
    ActiveMode := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetActiveMode(const AValue: TBCEditorSelectionMode);
begin
  if FActiveMode <> AValue then
  begin
    FActiveMode := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    DoChange;
  end;
end;

procedure TBCEditorSelection.SetOptions(AValue: TBCEditorSelectionOptions);
begin
  if FOptions <> AValue then
  begin
    FOptions := AValue;
    DoChange;
  end;
end;

end.
