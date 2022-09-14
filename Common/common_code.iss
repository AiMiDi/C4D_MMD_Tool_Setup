// 以下代码所有插件安装包通用，一般不需修改
// 各插件必须实现的函数：
//   GetInitInstallDir():String;
//   NeedPathSelectionPage():Boolean;
//   VerifyDirIsDccRoot):Boolean;

//-----------------------------------------------------------------------------------
// 由版本获取插件安装根目录
function InstallDir(Ver_str: string): String;
var
  index: Integer;
begin
  for index:=0 to {#VerCount}-1 do
  begin
    if DccVer[index]=Ver_str then
      Result := Edits[index].Text+'\';
  end
end;

// 自动配置插件安装路径。初始化安装路径，并存入Edit中
procedure InitInstallDir();
var
  install_dir:String;
  selectedFlag:String;
  num: Integer;
begin
  for num:=0 to {#VerCount}-1 do
  begin
    install_dir := GetInitInstallDir(DccVer[num]);
    
    // set component unselected if install_dir is empty
    if not (install_dir='') then
    begin
      Edits[num].Text := install_dir;
      selectedFlag := ''; 
    end
    else
      selectedFlag := '!';
    WizardSelectComponents(selectedFlag+'C_'+DccVer[num]);// "!C_2020", "C_2020"
  end;
end;

function ShouldSkipPage(CurPageID: Integer): Boolean;
begin
  result:=false;
  if CurPageID = PathSelectionPage.ID then
  begin  
    result:=not NeedPathSelectionPage();
  end;
end;

// --------------------------------------分割线------------------------------------------
// -以下代码所有插件安装包通用，一般不需修改

// "路径选择"页的"浏览"按钮实现
procedure ClickButton(Sender: TObject);
var num: Integer;
var install_dir: String;
begin
  for num := 0 to {#VerCount}-1 do  
  begin
    if Sender = Buttons[num] then
    begin
      install_dir := Edits[num].Text;    
      if BrowseForFolder('{#DCC_NAME}',install_dir , True) then
      begin
        install_dir := install_dir + '\';
        if VerifyDirIsDccRoot(install_dir) then
        begin
          Edits[num].Text := install_dir;
        end
        else
        begin
          Edits[num].Text := '';
          if ActiveLanguage='chinesesimplified' then
            MsgBox('路径错误！请选择 {#DCC_NAME} 的安装根目录。', mbError, MB_OK)
          else
            MsgBox('Wrong path! Please select the {#DCC_NAME} installation root directory.', mbError, MB_OK);// show warning dlg
        end;
      end;
      break;
    end
  end;
end;

// “路径选择”页，初始化控件
procedure InitControlsOfPathSelectionPage(PathSelPage: TwizardPage);
var
  ver_index: Integer;
  verCount_int: Integer;
  ControlTop,EditLeft,EditeWidth,ButtonLeft: Integer;
begin
  verCount_int:={#VerCount};
  
  ControlTop:=PathSelPage.SurfaceHeight*12/100;
  EditLeft:=PathSelPage.SurfaceWidth*3/10;
  EditeWidth:=PathSelPage.SurfaceWidth*74/100;
  ButtonLeft:=PathSelPage.SurfaceWidth*106/100;

  SetLength(DccVer,verCount_int);  
  SetLength(Labels,verCount_int);    
  SetLength(Edits,verCount_int);    
  SetLength(Buttons,verCount_int);

  for ver_index:= 0 to verCount_int-1 do
  begin
    Labels[ver_index]:=TLabel.Create(PathSelPage);
    Labels[ver_index].Parent:=PathSelPage.Surface;
    Labels[ver_index].Caption:='{#DCC_NAME} ' + DccVer[ver_index];
    Labels[ver_index].Top:=ControlTop*(ver_index+1);
    Edits[ver_index]:=TEdit.Create(PathSelPage);
    Edits[ver_index].Parent:=PathSelPage.Surface;
    Edits[ver_index].Left:=EditLeft;
    Edits[ver_index].Width:=EditeWidth;
    Edits[ver_index].Top:=ControlTop*(ver_index+1)-1;
    Buttons[ver_index]:=TButton.Create(PathSelPage);
    Buttons[ver_index].Parent:=PathSelPage.Surface;
    Buttons[ver_index].Caption:=SetupMessage(msgButtonWizardBrowse);
    Buttons[ver_index].Left:=ButtonLeft;
    Buttons[ver_index].Top:=ControlTop*(ver_index+1)-1;
      
    Buttons[ver_index].OnClick:=@ClickButton;
  end;
end;

// “路径选择”页，初始化页面
procedure InitPathSelectionPage;
var
  Lab0:TLabel;
begin
  // 创建自定义页面,用于配置插件安装路径
  PathSelectionPage := CreateCustomPage(wpSelectComponents, SetupMessage(msgWizardSelectDir), SetupMessage(msgSelectDirDesc));

  // 创建一个标题
  Lab0:=TLabel.Create(PathSelectionPage);Lab0.Parent:=PathSelectionPage.Surface;Lab0.Caption:=SetupMessage(msgSelectDirBrowseLabel);

  // 为每一个Component创建一组控件
  InitControlsOfPathSelectionPage(PathSelectionPage);
end;

// “路径选择”页，点击下一步按钮时，检查路径是否为正确的安装目录
function OnPathSelectionPageNext: Boolean;
var
  num: Integer;
begin
  result:=true;
  for num := 0 to {#VerCount}-1 do  
    begin
      if Edits[num].Text = '' then
      begin
        WizardSelectComponents('!C_'+DccVer[num]); // 组件名前加'!'，表示取消选中
      end
      else
      begin
        if not VerifyDirIsDccRoot(Edits[num].Text) then
        begin
          // show warning dlg        
          if ActiveLanguage='chinesesimplified' then
            MsgBox('路径错误！请填入 {#DCC_NAME} '+DccVer[num]+' 的安装根目录。', mbError, MB_OK)
          else
            MsgBox('Wrong path! Please fill in {#DCC_NAME} '+DccVer[num]+' installation root directory.', mbError, MB_OK);
          WizardForm.ActiveControl := Edits[num];// set edit focused
          result:=false;
          break;  
        end; 
      end;
    end;
end;  

// 安装程序初始化
procedure InitializeWizard();
begin
  MapVerArray();

  // 增加“路径选择”页，以支持手动修改安装路径，并确保安装路径正确
  InitPathSelectionPage();

  // 初始化安装目录
  InitInstallDir();
end;

function NextButtonClick(CurPageID:Integer): Boolean;
begin
  result:=true;
  // 在选择路径页点击下一步按钮时，检查路径是否为正确的安装目录
  if CurPageID = PathSelectionPage.ID then
  begin     
    result:=OnPathSelectionPageNext;
  end;
end;

// 自定义某个页面
procedure CurPageChanged(CurPageID: Integer);
begin
  // 隐藏“选择组件”页中的下拉框
  if CurPageID = wpSelectComponents then
    WizardForm.TypesCombo.Visible := false;
end;