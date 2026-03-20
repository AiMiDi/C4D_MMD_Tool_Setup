// 以下代码所有插件安装包通用，一般不需修改
// 各插件必须实现的函数：
//   GetInitInstallDir():String;
//   NeedPathSelectionPage():Boolean;
//   VerifyDirIsDccRoot():Boolean;

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
    
    if not (install_dir='') then
    begin
      Edits[num].Text := install_dir;
      selectedFlag := ''; 
    end
    else
      selectedFlag := '!';
    WizardSelectComponents(selectedFlag+DccComponentName[num]);
  end;
end;

function ShouldSkipPage(CurPageID: Integer): Boolean;
var
  i: Integer;
begin
  result:=false;
  if not NeedPathSelectionPage() then
  begin
    for i := 0 to GetArrayLength(PathSelectionPages) - 1 do
    begin
      if CurPageID = PathSelectionPages[i].ID then
      begin
        result := true;
        break;
      end;
    end;
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
            MsgBox('Wrong path! Please select the {#DCC_NAME} installation root directory.', mbError, MB_OK);
        end;
      end;
      break;
    end
  end;
end;

// "路径选择"页，初始化控件
procedure InitControlsOfPathSelectionPage(PathSelPage: TwizardPage; PathSelPageIndex: Integer; ItemsPerPage: Integer);
var
  ui_index, ver_index, ver_index_begin, ver_index_end, verCount_int: Integer;
  ControlTop, EditLeft, EditWidth, ButtonWidth, ButtonLeft: Integer;
begin
  verCount_int:={#VerCount};
  ver_index_begin := PathSelPageIndex * ItemsPerPage;

  ControlTop:=PathSelPage.SurfaceHeight*12/100;
  EditLeft:=PathSelPage.SurfaceWidth*3/10;
  ButtonWidth:=ScaleX(80);
  ButtonLeft:=PathSelPage.SurfaceWidth - ButtonWidth;
  EditWidth:=ButtonLeft - EditLeft - ScaleX(6);

  if ver_index_begin + ItemsPerPage > verCount_int then
    ver_index_end := verCount_int
  else
    ver_index_end := ver_index_begin + ItemsPerPage;

  ui_index:=1;
  for ver_index:= ver_index_begin to ver_index_end - 1 do
  begin
    Labels[ver_index]:=TLabel.Create(PathSelPage);
    Labels[ver_index].Parent:=PathSelPage.Surface;
    Labels[ver_index].Caption:='{#DCC_NAME} ' + DccVer[ver_index];
    Labels[ver_index].Top:=ControlTop*(ui_index);
    Edits[ver_index]:=TEdit.Create(PathSelPage);
    Edits[ver_index].Parent:=PathSelPage.Surface;
    Edits[ver_index].Left:=EditLeft;
    Edits[ver_index].Width:=EditWidth;
    Edits[ver_index].Top:=ControlTop*(ui_index)-1;
    Buttons[ver_index]:=TButton.Create(PathSelPage);
    Buttons[ver_index].Parent:=PathSelPage.Surface;
    Buttons[ver_index].Caption:=SetupMessage(msgButtonWizardBrowse);
    Buttons[ver_index].Width:=ButtonWidth;
    Buttons[ver_index].Left:=ButtonLeft;
    Buttons[ver_index].Top:=ControlTop*(ui_index)-1;
    Buttons[ver_index].OnClick:=@ClickButton;
    ui_index:=ui_index+1;
  end;
end;

// "路径选择"页，初始化页面（均匀分页，每页最多10个版本）
procedure InitPathSelectionPage;
var
  Labs: array of TLabel;
  PageNum, PageIndex, verCount, ItemsPerPage: Integer;
begin
  verCount:={#VerCount};
  // 先按上限10算出总页数，再均匀分配每页条目数
  PageNum := (verCount + 9) div 10;
  ItemsPerPage := (verCount + PageNum - 1) div PageNum;

  SetLength(PathSelectionPages, PageNum);
  SetLength(Labs, PageNum);
  SetLength(DccVer, verCount);
  SetLength(DccComponentName, verCount);
  SetLength(Labels, verCount);
  SetLength(Edits, verCount);
  SetLength(Buttons, verCount);

  // 倒序创建页面，使 Page 0 紧跟在 wpSelectComponents 之后
  for PageIndex := PageNum - 1 downto 0 do
  begin
    PathSelectionPages[PageIndex] := CreateCustomPage(wpSelectComponents, SetupMessage(msgWizardSelectDir), SetupMessage(msgSelectDirDesc));

    Labs[PageIndex]:=TLabel.Create(PathSelectionPages[PageIndex]);
    Labs[PageIndex].Parent:=PathSelectionPages[PageIndex].Surface;
    Labs[PageIndex].Caption:=SetupMessage(msgSelectDirBrowseLabel);

    InitControlsOfPathSelectionPage(PathSelectionPages[PageIndex], PageIndex, ItemsPerPage);
  end;
  PathSelectionPageEndID := PathSelectionPages[PageNum - 1].ID;
end;

// "路径选择"页，点击下一步按钮时，检查路径是否为正确的安装目录
function OnPathSelectionPageNext: Boolean;
var
  num: Integer;
begin
  result:=true;
  for num := 0 to {#VerCount}-1 do  
    begin
      if Edits[num].Text = '' then
      begin
        WizardSelectComponents('!'+DccComponentName[num]);
      end
      else
      begin
        if not VerifyDirIsDccRoot(Edits[num].Text) then
        begin
          if ActiveLanguage='chinesesimplified' then
            MsgBox('路径错误！请填入 {#DCC_NAME} '+DccVer[num]+' 的安装根目录。', mbError, MB_OK)
          else
            MsgBox('Wrong path! Please fill in {#DCC_NAME} '+DccVer[num]+' installation root directory.', mbError, MB_OK);
          WizardForm.ActiveControl := Edits[num];
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

  // 增加"路径选择"页，以支持手动修改安装路径，并确保安装路径正确
  InitPathSelectionPage();

  // 初始化安装目录
  InitInstallDir();
end;

function NextButtonClick(CurPageID:Integer): Boolean;
begin
  result:=true;
  if CurPageID = PathSelectionPageEndID then
  begin     
    result:=OnPathSelectionPageNext;
  end;
end;

// 自定义某个页面
procedure CurPageChanged(CurPageID: Integer);
begin
  // 隐藏"选择组件"页中的下拉框
  if CurPageID = wpSelectComponents then
    WizardForm.TypesCombo.Visible := false;
end;
