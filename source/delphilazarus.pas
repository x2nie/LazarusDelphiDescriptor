{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DelphiLazarus;

interface

uses
  delphi_descriptors, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('delphi_descriptors', @delphi_descriptors.Register);
end;

initialization
  RegisterPackage('DelphiLazarus', @Register);
end.
