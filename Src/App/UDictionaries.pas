{ ##
  @FILE                     UDictionaries.pas
  @COMMENTS                 Defines classes that implement dictionaries (or
                            associatve arrays).
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 23/05/2004
      @COMMENTS             Original version
    )
  )
}


{
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UDictionaries.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UDictionaries;


interface


uses
  // Delphi
  Classes;


type

  {
  TBaseDictionary:
    Base class for objects that implement dictionaries (or associative arrays).

    Inheritance: TBaseDictionary -> [TObject]
  }
  TBaseDictionary = class(TObject)
  private // properties
    function GetCapacity: Integer;
    procedure SetCapacity(const Value: Integer);
    function GetCount: Integer;
  private
    fDict: TStringList;
      {Data structure used to store dictionary}
  protected
    function InternalGetName(Idx: Integer): string;
      {Returns name of dictionary item at given index or '' if index is out of
      range}
    function InternalSetItem(const Name: string; Value: Pointer): Boolean;
      {Sets dictionary item with given name and value If an item with the same
      name already exists its value is overwritten and true is returned. If the
      item doesn't exist it is added and false is returned}
    function InternalGetItem(const Name: string): Pointer; overload;
      {Returns value for dictionary item with given name. Returns nil if item
      does not exist}
    function InternalGetItem(Idx: Integer): Pointer; overload;
      {Returns value for dictionary item at the given index. Returns nil if
      index is out of range}
    procedure InternalDeleteItem(Idx: Integer); virtual;
      {Deletes item with given index, which must be in range}
    function IndexOfName(const Name: string): Integer;
      {Returns index of given name in dictionary or -1 if not present}
  public
    constructor Create;
      {Class constructor: creates an empty dictionary}
    destructor Destroy; override;
      {Class destructor: destroys dictionary}
    procedure Clear;
      {Clears dictionary}
    function Delete(const Name: string): Boolean;
      {Deletes the dictionary item with the given name if present in the
      dictionary. Returns true if the item was deleted and false if the item
      was not in the dictionary}
    function Exists(const Name: string): Boolean;
      {Returns true if the given item exists in the dictionary and false
      otherwise}
    property Capacity: Integer read GetCapacity write SetCapacity;
      {The capacity of the dictionary: set this to pre-allocate space. Attempts
      to set Capacity to less than Count are ignored}
    property Count: Integer read GetCount;
      {The number of entries in the dictionary}
  end;


  {
  TBitMaskDictionary:
    Dictionary object that maps names to 32 bit bit masks.

    Inheritance: TBitMaskDictionary -> TBaseDictionary -> [TObject]
  }
  TBitMaskDictionary = class(TBaseDictionary)
  private // properties
    function GetName(Idx: Integer): string;
  protected // properties
    function GetValue(const Name: string): Cardinal;
    function GetValueByIdx(Idx: Integer): Cardinal;
    procedure SetValue(const Name: string; const Value: Cardinal);
  public
    property Names[Idx: Integer]: string read GetName;
      {Names of keys to dictionary: if index is out of range '' is returned}
    property Values[const Name: string]: Cardinal read GetValue write SetValue;
      {Bitmasks associated with given key name. Reading an unknown key name
      returns 0. Setting a Key name that doesn't exist creates the key name}
    property ValuesByIdx[Idx: Integer]: Cardinal read GetValueByIdx;
      {Provides read access to value bitmasks by index}
  end;


implementation


{ TBaseDictionary }

procedure TBaseDictionary.Clear;
  {Clears dictionary}
var
  Idx: Integer; // loops thru all items in dictionary
begin
  // Delete each item in dictionary
  for Idx := Pred(Count) downto 0 do
    InternalDeleteItem(Idx);
end;

constructor TBaseDictionary.Create;
  {Class constructor: creates an empty dictionary}
begin
  inherited Create;
  // Create sorted, case insensitive string list to store dictionary
  fDict := TStringList.Create;
  fDict.CaseSensitive := False;
  fDict.Sorted := True;
  fDict.Duplicates := dupError;
end;

function TBaseDictionary.Delete(const Name: string): Boolean;
  {Deletes the dictionary item with the given name if present in the dictionary.
  Returns true if the item was deleted and false if the item was not in the
  dictionary}
var
  Idx: Integer; // index of name in dictionary
begin
  Idx := IndexOfName(Name);
  Result := (Idx >= 0) and (Idx < Count);
  if Result then
    InternalDeleteItem(Idx);
end;

destructor TBaseDictionary.Destroy;
  {Class destructor: destroys dictionary}
begin
  Clear;        // clear dictionary
  fDict.Free;   // free dictionary
  inherited;
end;

function TBaseDictionary.Exists(const Name: string): Boolean;
  {Returns true if the given item exists in the dictionary and false otherwise}
begin
  Result := IndexOfName(Name) > -1;
end;

function TBaseDictionary.GetCapacity: Integer;
  {Read accessor for Capacity property}
begin
  Result := fDict.Capacity;
end;

function TBaseDictionary.GetCount: Integer;
  {Read accessor for Count property}
begin
  Result := fDict.Count;
end;

function TBaseDictionary.IndexOfName(const Name: string): Integer;
  {Returns index of given name in dictionary or -1 if not present}
begin
  Result := fDict.IndexOf(Name);
end;

procedure TBaseDictionary.InternalDeleteItem(Idx: Integer);
  {Deletes item with given index, which must be in range}
begin
  fDict.Delete(Idx);
end;

function TBaseDictionary.InternalGetItem(Idx: Integer): Pointer;
  {Returns value for dictionary item at the given index. Returns nil if index is
  out of range}
begin
  if (Idx >= 0) and (Idx < Count) then
    Result := fDict.Objects[Idx]
  else
    Result := nil;
end;

function TBaseDictionary.InternalGetItem(const Name: string): Pointer;
  {Returns value for dictionary item with given name. Returns nil if item does
  not exist}
var
  Idx: Integer; // index of name in dictionary
begin
  Idx := IndexOfName(Name);
  Result := InternalGetItem(Idx);
end;

function TBaseDictionary.InternalGetName(Idx: Integer): string;
  {Returns name of dictionary item at given index or '' if index is out of
  range}
begin
  if (Idx >= 0) and (Idx < Count) then
    Result := fDict[Idx]
  else
    Result := '';
end;

function TBaseDictionary.InternalSetItem(const Name: string;
  Value: Pointer): Boolean;
  {Sets dictionary item with given name and value If an item with the same name
  already exists its value is overwritten and true is returned. If the item
  doesn't exist it is added and false is returned}
var
  Idx: Integer; // index of name in dictionary
begin
  Idx := IndexOfName(Name);
  Result := Idx > -1;
  if Result then
    fDict.Objects[Idx] := Value
  else
    fDict.AddObject(Name, Value);
end;

procedure TBaseDictionary.SetCapacity(const Value: Integer);
  {Write accessor for Capacity property: ignores capacity if smaller than number
  of items in dictionary}
begin
  if Value >= Count then
    fDict.Capacity := Value;
end;


{ TBitMaskDictionary }

function TBitMaskDictionary.GetName(Idx: Integer): string;
  {Read accessor for Names[] property}
begin
  Result := inherited InternalGetName(Idx);
end;

function TBitMaskDictionary.GetValue(const Name: string): Cardinal;
  {Read accessor for Values[] property}
begin
  Result := Cardinal(inherited InternalGetItem(Name));
end;

function TBitMaskDictionary.GetValueByIdx(Idx: Integer): Cardinal;
  {Read accessor for ValuesByIdx[] property}
begin
  Result := Cardinal(inherited InternalGetItem(Idx));
end;

procedure TBitMaskDictionary.SetValue(const Name: string;
  const Value: Cardinal);
  {Write accessor for Values[] property}
begin
  inherited InternalSetItem(Name, Pointer(Value));
end;

end.
