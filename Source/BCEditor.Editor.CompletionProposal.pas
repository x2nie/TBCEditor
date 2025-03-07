unit BCEditor.Editor.CompletionProposal;

interface

uses
  System.Classes, Vcl.Graphics, BCEditor.Editor.CompletionProposal.Colors, BCEditor.Editor.CompletionProposal.Columns,
  BCEditor.Editor.CompletionProposal.Trigger, BCEditor.Types;

type
  TBCEditorCompletionProposal = class(TPersistent)
  strict private
    FCloseChars: string;
    FColors: TBCEditorCompletionProposalColors;
    FColumns: TBCEditorProposalColumns;
    FCompletionColumnIndex: Integer;
    FEnabled: Boolean;
    FFont: TFont;
    FOptions: TBCEditorCompletionProposalOptions;
    FOwner: TPersistent;
    FShortCut: TShortCut;
    FTrigger: TBCEditorCompletionProposalTrigger;
    FVisibleLines: Integer;
    FWidth: Integer;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
  published
    property CloseChars: string read FCloseChars write FCloseChars;
    property Colors: TBCEditorCompletionProposalColors read FColors write FColors;
    property Columns: TBCEditorProposalColumns read FColumns write FColumns;
    property CompletionColumnIndex: Integer read FCompletionColumnIndex write FCompletionColumnIndex default 0;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Font: TFont read FFont write FFont;
    property Options: TBCEditorCompletionProposalOptions read FOptions write FOptions default [cpoFiltered, cpoParseItemsFromText, cpoResizeable];
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property Trigger: TBCEditorCompletionProposalTrigger read FTrigger write FTrigger;
    property VisibleLines: Integer read FVisibleLines write FVisibleLines default 8;
    property Width: Integer read FWidth write FWidth default 260;
  end;

implementation

uses
  Vcl.Menus;

{ TBCEditorCompletionProposal }

constructor TBCEditorCompletionProposal.Create(AOwner: TPersistent);
begin
  inherited Create;

  FOwner := AOwner;
  FCloseChars := '()[]. ';
  FColors := TBCEditorCompletionProposalColors.Create;
  FColumns := TBCEditorProposalColumns.Create(Self, TBCEditorProposalColumn);
  FColumns.Add; { default column }
  FCompletionColumnIndex := 0;
  FEnabled := True;
  FFont := TFont.Create;
  FFont.Name := 'Courier New';
  FFont.Size := 8;
  FOptions := [cpoFiltered, cpoParseItemsFromText, cpoResizeable];
  FShortCut := Vcl.Menus.ShortCut(Ord(' '), [ssCtrl]);
  FTrigger := TBCEditorCompletionProposalTrigger.Create;
  FVisibleLines := 8;
  FWidth := 260;
end;

destructor TBCEditorCompletionProposal.Destroy;
begin
  FColors.Free;
  FFont.Free;
  FTrigger.Free;
  FColumns.Free;

  inherited;
end;

procedure TBCEditorCompletionProposal.Assign(ASource: TPersistent);
begin
  if ASource is TBCEditorCompletionProposal then
  with ASource as TBCEditorCompletionProposal do
  begin
    Self.FCloseChars := FCloseChars;
    Self.FColors.Assign(FColors);
    Self.FColumns.Assign(FColumns);
    Self.FEnabled := FEnabled;
    Self.FFont.Assign(FFont);
    Self.FOptions := FOptions;
    Self.FShortCut := FShortCut;
    Self.FTrigger.Assign(FTrigger);
    Self.FVisibleLines := FVisibleLines;
    Self.FWidth := FWidth;
  end
  else
    inherited Assign(ASource);
end;

function TBCEditorCompletionProposal.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

end.
