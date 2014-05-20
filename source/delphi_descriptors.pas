{
  Delphi Project Descriptor
  =========================
  It allow creating:
    * Delphi project (*.dpr)
    * Delphi unit file (*.pas + *.dfm)
    * etc., more delphi stuff in future; such delphi package (*.dpk)
  within Lazarus.

  Author : x2nie 
  Years  : 2014-05-20

  Download/update : https://github.com/x2nie/LazarusDelphiDescriptor
  
  see:   
    http://forum.lazarus.freepascal.org/index.php/topic,24596.0.html
    http://bugs.freepascal.org/view.php?id=26192

  Install:
    currently, need a patch applied to Lazarus. Download here: http://bugs.freepascal.org/view.php?id=26192


  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit delphi_descriptors;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms;
type
  { TDelphiApplicationDescriptor }

  TDelphiApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject): TModalResult; override;
  end;

{ TFileDescPascalUnitWithDelphiForm }

  TFileDescPascalUnitWithDelphiForm = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetUnitDirectives: string; override;
  end;


procedure Register;

implementation


procedure Register;
begin
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithDelphiForm.Create,
                                FileDescGroupName);
  RegisterProjectDescriptor(TDelphiApplicationDescriptor.Create);
end;

function FileDescriptorHDForm() : TProjectFileDescriptor;
begin
  Result:=ProjectFileDescriptors.FindByName('Delphi Form');
end;

{ TFileDescPascalUnitWithlpForm }

constructor TFileDescPascalUnitWithDelphiForm.Create;
begin
  inherited Create;
  Name:='Delphi Form';
  DefaultResFileExt := '.dfm';
  ResourceClass:=TForm;
  UseCreateFormStatements:=true;
end;

function TFileDescPascalUnitWithDelphiForm.GetInterfaceUsesSection: string;
begin
  Result:='Classes, SysUtils, Forms';
end;

function TFileDescPascalUnitWithDelphiForm.GetLocalizedName: string;
begin
  Result:='Delphi Form';
end;

function TFileDescPascalUnitWithDelphiForm.GetLocalizedDescription: string;
begin
  Result:='Create a new blank Delphi Form';
end;

function TFileDescPascalUnitWithDelphiForm.GetUnitDirectives: string;
begin
  result := inherited GetUnitDirectives();
  result := '{$ifdef fpc}'+ LineEnding
           +result + LineEnding
           +'{$endif}';
end;

{ TProjectApplicationDescriptor }

constructor TDelphiApplicationDescriptor.Create;
begin
  inherited;
  Name := 'A blank Delphi application';
end;

function TDelphiApplicationDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorHDForm,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;

function TDelphiApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result := 'Delphi Application'+LineEnding+LineEnding
           +'A Delphi GUI application compatible with Lazarus.'+LineEnding
           +'This files will be automatically maintained by Lazarus.';
end;

function TDelphiApplicationDescriptor.GetLocalizedName: string;
begin
  Result := 'Delphi Application';
end;

function TDelphiApplicationDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.dpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  AProject.UseAppBundle:=true;
  AProject.UseManifest:=true;
  AProject.LoadDefaultIcon;
  AProject.LazCompilerOptions.SyntaxMode:='Delphi';


  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$ifdef fpc}'+LineEnding
    +'{$mode delphi}{$H+}'+LineEnding
    +'{$endif}'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    +'  {$ifdef fpc}'+LineEnding
    +'  {$IFDEF UNIX}{$IFDEF UseCThreads}'+LineEnding
    +'  cthreads,'+LineEnding
    +'  {$ENDIF}{$ENDIF}'+LineEnding
    +'  Interfaces, // this includes the LCL widgetset'+LineEnding
    +'  {$endif}'+LineEnding
    +'  Forms'+LineEnding
    +'  { you can add units after this };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    //+'  RequireDerivedFormResource := True;'+LineEnding
    +'  Application.Initialize;'+LineEnding
    +'  Application.Run;'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  // add lcl pp/pas dirs to source search path
  AProject.AddPackageDependency('FCL');
  AProject.LazCompilerOptions.Win32GraphicApp:=true;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

end.

