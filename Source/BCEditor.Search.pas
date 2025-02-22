unit BCEditor.Search;

interface

uses
  System.Classes;

type
  TBCEditorSearchCustom = class
  protected
    function GetLength(AIndex: Integer): Integer; virtual; abstract;
    function GetPattern: string; virtual; abstract;
    function GetResult(AIndex: Integer): Integer; virtual; abstract;
    function GetResultCount: Integer; virtual; abstract;
    procedure SetPattern(const AValue: string); virtual; abstract;
  public
    function FindAll(const AText: string): Integer; virtual; abstract;
    function Replace(const AOccurrence, aReplacement: string): string; virtual; abstract;
    procedure Clear; virtual; abstract;
    property Lengths[AIndex: Integer]: Integer read GetLength;
    property Pattern: string read GetPattern write SetPattern;
    property ResultCount: Integer read GetResultCount;
    property Results[AIndex: Integer]: Integer read GetResult;
  end;

  { TBCEditorNormalSearch }

  TBCEditorNormalSearch = class(TBCEditorSearchCustom)
  strict private
    FCaseSensitive: Boolean;
    FCount: Integer;
    FLookAt: Integer;
    FOrigin: PChar;
    FPattern, FCasedPattern: string;
    FPatternLength, FPatternLengthSuccessor: Integer;
    FResults: TList;
    FRun: PChar;
    FShift: array [AnsiChar] of Integer;
    FShiftInitialized: Boolean;
    FTextLength: Integer;
    FTextToSearch: string;
    FTheEnd: PChar;
    FWholeWordsOnly: Boolean;
    function GetFinished: Boolean;
    procedure InitShiftTable;
    procedure SetCaseSensitive(const AValue: Boolean);
  protected
    function GetLength(AIndex: Integer): Integer; override;
    function GetPattern: string; override;
    function GetResult(AIndex: Integer): Integer; override;
    function GetResultCount: Integer; override;
    function TestWholeWord: Boolean;
    procedure SetPattern(const AValue: string); override;
  public
    constructor Create;
    destructor Destroy; override;

    function FindAll(const AText: string): Integer; override;
    function FindFirst(const AText: string): Integer;
    function Next: Integer;
    function Replace(const AOccurrence, AReplacement: string): string; override;
    procedure Clear; override;
    procedure FixResults(AFirst, ADelta: Integer);
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property Count: Integer read FCount write FCount;
    property Finished: Boolean read GetFinished;
    property Pattern read FCasedPattern;
    property WholeWordsOnly: Boolean read FWholeWordsOnly write FWholeWordsOnly;
  end;

implementation

uses
  System.SysUtils, System.Character, BCEditor.Consts;

constructor TBCEditorNormalSearch.Create;
begin
  inherited;
  FResults := TList.Create;
end;

function TBCEditorNormalSearch.GetFinished: Boolean;
begin
  Result := (FRun >= FTheEnd) or (FPatternLength >= FTextLength);
end;

function TBCEditorNormalSearch.GetResult(AIndex: Integer): Integer;
begin
  Result := 0;
  if (AIndex >= 0) and (AIndex < FResults.Count) then
    Result := Integer(FResults[AIndex]);
end;

function TBCEditorNormalSearch.GetResultCount: Integer;
begin
  Result := FResults.Count;
end;

procedure TBCEditorNormalSearch.FixResults(AFirst, ADelta: Integer);
var
  i: Integer;
begin
  if (ADelta <> 0) and (FResults.Count > 0) then
  begin
    i := FResults.Count - 1;
    while i >= 0 do
    begin
      if Integer(FResults[i]) <= AFirst then
        Break;
      FResults[i] := pointer(Integer(FResults[i]) - ADelta);
      Dec(i);
    end;
  end;
end;

procedure TBCEditorNormalSearch.InitShiftTable;
var
  LAnsiChar: AnsiChar;
  i: Integer;
begin
  FPatternLength := Length(FPattern);
  if FPatternLength = 0 then
    raise Exception.Create('Pattern is empty');
  FPatternLengthSuccessor := FPatternLength + 1;
  FLookAt := 1;
  for LAnsiChar := Low(AnsiChar) to High(AnsiChar) do
    FShift[LAnsiChar] := FPatternLengthSuccessor;
  for i := 1 to FPatternLength do
    FShift[AnsiChar(FPattern[i])] := FPatternLengthSuccessor - i;
  while FLookAt < FPatternLength do
  begin
    if FPattern[FPatternLength] = FPattern[FPatternLength - FLookAt] then
      break;
    Inc(FLookAt);
  end;
  FShiftInitialized := True;
end;

function TBCEditorNormalSearch.TestWholeWord: Boolean;
var
  LPTest: PChar;

  function IsWordBreakChar(AChar: Char): Boolean;
  begin
    if (AChar < BCEDITOR_EXCLAMATION_MARK) or AChar.IsWhiteSpace then
      Result := True
    else
    if AChar = BCEDITOR_LOW_LINE then
      Result := False
    else
      Result := not AChar.IsLetterOrDigit;
  end;

begin
  LPTest := FRun - FPatternLength;

  Result := ((LPTest < FOrigin) or IsWordBreakChar(LPTest[0])) and ((FRun >= FTheEnd) or IsWordBreakChar(FRun[1]));
end;

function TBCEditorNormalSearch.Next: Integer;
var
  i: Integer;
  LPValue: PChar;
begin
  Result := 0;
  Inc(FRun, FPatternLength);
  while FRun < FTheEnd do
  begin
    if FPattern[FPatternLength] <> FRun^ then
      Inc(FRun, FShift[AnsiChar((FRun + 1)^)])
    else
    begin
      LPValue := FRun - FPatternLength + 1;
      i := 1;
      while FPattern[i] = LPValue^ do
      begin
        if i = FPatternLength then
        begin
          if FWholeWordsOnly then
            if not TestWholeWord then
              Break;
          Inc(FCount);
          Result := FRun - FOrigin - FPatternLength + 2;
          Exit;
        end;
        Inc(i);
        Inc(LPValue);
      end;
      Inc(FRun, FLookAt);
      if FRun >= FTheEnd then
        Break;
      Inc(FRun, FShift[AnsiChar(FRun^)] - 1);
    end;
  end;
end;

destructor TBCEditorNormalSearch.Destroy;
begin
  FResults.Free;
  inherited Destroy;
end;

procedure TBCEditorNormalSearch.SetPattern(const AValue: string);
begin
  if FPattern <> AValue then
  begin
    FCasedPattern := AValue;
    if CaseSensitive then
      FPattern := FCasedPattern
    else
      FPattern := LowerCase(FCasedPattern);
    FShiftInitialized := False;
  end;
  FCount := 0;
end;

procedure TBCEditorNormalSearch.SetCaseSensitive(const AValue: Boolean);
begin
  if FCaseSensitive <> AValue then
  begin
    FCaseSensitive := AValue;
    if FCaseSensitive then
      FPattern := FCasedPattern
    else
      FPattern := LowerCase(FCasedPattern);
    FShiftInitialized := False;
  end;
end;

procedure TBCEditorNormalSearch.Clear;
begin
  FResults.Count := 0;
end;

function TBCEditorNormalSearch.FindAll(const AText: string): Integer;
var
  Found: Integer;
begin
  Clear;
  Found := FindFirst(AText);
  while Found > 0 do
  begin
    FResults.Add(Pointer(Found));
    Found := Next;
  end;
  Result := FResults.Count;
end;

function TBCEditorNormalSearch.Replace(const AOccurrence, AReplacement: string): string;
begin
  Result := AReplacement;
end;

function TBCEditorNormalSearch.FindFirst(const AText: string): Integer;
begin
  if not FShiftInitialized then
    InitShiftTable;
  Result := 0;
  FTextLength := Length(AText);
  if FTextLength >= FPatternLength then
  begin
    if CaseSensitive then
      FTextToSearch := AText
    else
      FTextToSearch := AnsiLowerCase(AText);
    FOrigin := PChar(FTextToSearch);
    FTheEnd := FOrigin + FTextLength;
    FRun := FOrigin - 1;
    Result := Next;
  end;
end;

function TBCEditorNormalSearch.GetLength(AIndex: Integer): Integer;
begin
  Result := FPatternLength;
end;

function TBCEditorNormalSearch.GetPattern: string;
begin
  Result := FCasedPattern;
end;

end.

