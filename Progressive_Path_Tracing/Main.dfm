object MainForm: TMainForm
  Left = 198
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Progressive Path Tracing'
  ClientHeight = 587
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000040040000000000000000000000000000000000000000
    000000000000000000000000001B0000001D0000000000000000000000000000
    000000000000000000200000002E000000000000000000000000000000000000
    00000000000000000000000000AA000000FF0000003B00000000000000000000
    00000000004F000000FB000000FF0000006A0000000000000000000000000000
    0000000000000000000000000034000000FF000000AC00000000000000000000
    0000000000CA0000008D00000041000000AE0000000000000000000000000000
    0000000000000000000000000000000000BC000000FC00000021000000000000
    0015000000D30000000100000000000000560000000000000000000000000000
    000000000000000000000000000000000046000000FF0000008E000000000000
    004E0000007E0000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000001000000CE000000F00000000E0000
    00860000003F0000000000000000000000000000000000000000000000000000
    00000000000000000000000000000000000000000058000000FF0000006F0000
    00BA0000000A0000000000000000000000000000000000000000000000000000
    00000000000000000000000000000000000000000004000000DD000000DE0000
    00C0000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000006B000000FF0000
    0092000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000A000000EA0000
    0059000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000B00000
    001E000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000002000000000000000000000002000000C80000
    0000000000000000000000000000000000000000000000000000000000000000
    00000000000000000000000000670000000300000000000000430000009E0000
    0000000000000000000000000000000000000000000000000000000000000000
    00000000000000000000000000470000009200000045000000D60000004E0000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000003000000C4000000FF000000C3000000030000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000070000003900000007000000000000
    000000000000000000000000000000000000000000000000000000000000E7CF
    0000E3870000E3870000F1170000F13F0000F03F0000F83F0000F87F0000FC7F
    0000FC7F0000FE7F0000ECFF0000E4FF0000E0FF0000E0FF0000F1FF0000}
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Img: TImage
    Left = 0
    Top = 56
    Width = 512
    Height = 512
    Align = alClient
  end
  object ProgIcon: TImage
    Left = 168
    Top = 64
    Width = 32
    Height = 32
    Picture.Data = {
      055449636F6E0000010001002020000001002000A81000001600000028000000
      2000000040000000010020000000000080100000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000032
      0000003B0000003B000000390000000100000000000000000000000000000000
      000000000000000000000000000000000000000000000015000000690000007D
      0000003B00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000091
      000000FF000000FF000000FF0000003F00000000000000000000000000000000
      0000000000000000000000000000000000000046000000EF000000FF000000FF
      000000FE0000007B000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000001F
      000000FA000000FF000000FF000000AF00000000000000000000000000000000
      0000000000000000000000000000000E000000EA000000FF000000FF000000FF
      000000FF000000FD000000300000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000A3000000FF000000FF000000FC00000023000000000000000000000000
      0000000000000000000000000000006A000000FF000000FF000000B20000006D
      00000095000000FB0000008D0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000002E000000FE000000FF000000FF00000091000000000000000000000000
      000000000000000000000000000000C0000000FF000000850000000000000000
      0000000000000070000000C20000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000B5000000FF000000FF000000F1000000100000000000000000
      00000000000000000000000D000000FA000000DC000000050000000000000000
      000000000000000C000000D70000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000003F000000FF000000FF000000FF000000730000000000000000
      000000000000000000000046000000FF00000075000000000000000000000000
      0000000000000000000000760000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000001000000C7000000FF000000FF000000DF0000000400000000
      00000000000000000000007F000000FE00000022000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000051000000FF000000FF000000FF0000005400000000
      0000000000000000000000B7000000D900000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000002000000D7000000FF000000FF000000C500000000
      0000000000000002000000EE0000009B00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000063000000FF000000FF000000FF00000036
      000000000000002A000000FF0000006100000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000007000000E5000000FF000000FF000000A7
      0000000000000062000000FF0000002800000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000076000000FF000000FF000000FA
      0000001D0000009A000000EC0000000100000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000F000000EF000000FF000000FF
      00000088000000D3000000B40000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000088000000FF000000FF
      000000F0000000FC0000007B0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000019000000F7000000FF
      000000FF000000FF000000420000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000009A000000FF
      000000FF000000FB0000000D0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000026000000FD
      000000FF000000CE000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000AC
      000000FF00000094000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000050
      000000FF0000005A000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000074
      000000FF0000001E000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000B0
      000000DF00000001000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000009000000000000000000000000000000000000000000000007000000F1
      000000A100000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000001
      000000C200000000000000000000000000000000000000000000004F000000FF
      0000006000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000DA0000000D00000000000000000000000000000000000000BD000000FE
      0000001B00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000B50000008F00000001000000000000000000000060000000FF000000CB
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000068000000FF000000BC000000770000009E000000FC000000FF0000006C
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000B000000E3000000FF000000FF000000FF000000FF000000E30000000B
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000003C000000F1000000FF000000FF000000F00000003C00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000001D00000072000000730000001C0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FFFFFFFFFC1FF0FFFC1FE07FFC1FC03FFE0FC03FFE0FC73FFF07873F
      FF078FBFFF038FFFFF839FFFFF831FFFFFC11FFFFFC11FFFFFE01FFFFFE03FFF
      FFF03FFFFFF03FFFFFF83FFFFFF87FFFFFFC7FFFFFFC7FFFFFFC7FFFFFFC7FFF
      FEF8FFFFFCF8FFFFFE78FFFFFE31FFFFFE01FFFFFE01FFFFFF03FFFFFF87FFFF
      FFFFFFFF}
    Visible = False
  end
  object Toolbar: TToolBar
    Left = 0
    Top = 0
    Width = 512
    Height = 56
    AutoSize = True
    ButtonHeight = 54
    ButtonWidth = 55
    Caption = 'Toolbar'
    Flat = True
    Images = ToolImages
    TabOrder = 0
    object SceneSelectionBtn: TToolButton
      Left = 0
      Top = 0
      Hint = 'Select a scene here'
      Caption = 'test'
      DropdownMenu = SceneMenu
      ImageIndex = 0
      Style = tbsDropDown
      OnClick = SceneSelectionBtnClick
    end
    object SepBtn2: TToolButton
      Left = 70
      Top = 0
      Width = 8
      Caption = 'SepBtn2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object SettingsBtn: TToolButton
      Left = 78
      Top = 0
      Hint = 'Change rendering settings here'
      Caption = 'SettingsBtn'
      DropdownMenu = SettingsMenu
      ImageIndex = 1
      Style = tbsDropDown
      OnClick = SettingsBtnClick
    end
    object SepBtn1: TToolButton
      Left = 148
      Top = 0
      Width = 8
      Caption = 'SepBtn1'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object PlayPauseBtn: TToolButton
      Left = 156
      Top = 0
      Hint = 'Suspends or resumes rendering'
      Caption = 'PlayPauseBtn'
      Enabled = False
      ImageIndex = 2
      OnClick = PlayPauseBtnClick
    end
    object StopBtn: TToolButton
      Left = 211
      Top = 0
      Hint = 'Stops rendering the scene and saves the result'
      Caption = 'StopBtn'
      Enabled = False
      ImageIndex = 4
      OnClick = StopBtnClick
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 568
    Width = 512
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolImages: TImageList
    Height = 48
    Width = 48
    Left = 72
    Top = 64
  end
  object SceneMenu: TPopupMenu
    Left = 8
    Top = 64
  end
  object SettingsMenu: TPopupMenu
    Left = 40
    Top = 64
    object Resolution1: TMenuItem
      Caption = 'Resolution'
      object N32x321: TMenuItem
        Tag = 5
        Caption = '32'#215'32'
        GroupIndex = 1
        RadioItem = True
        OnClick = N32x321Click
      end
      object N64641: TMenuItem
        Tag = 6
        Caption = '64'#215'64'
        GroupIndex = 1
        RadioItem = True
        OnClick = N32x321Click
      end
      object N1281281: TMenuItem
        Tag = 7
        Caption = '128'#215'128'
        Checked = True
        GroupIndex = 1
        RadioItem = True
        OnClick = N32x321Click
      end
      object N2562561: TMenuItem
        Tag = 8
        Caption = '256'#215'256'
        GroupIndex = 1
        RadioItem = True
        OnClick = N32x321Click
      end
      object N5125121: TMenuItem
        Tag = 9
        Caption = '512'#215'512'
        GroupIndex = 1
        RadioItem = True
        OnClick = N32x321Click
      end
    end
    object Samplestep1: TMenuItem
      Caption = 'Sample step'
      object N11: TMenuItem
        Tag = 1
        Caption = '1'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N21: TMenuItem
        Tag = 2
        Caption = '2'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N51: TMenuItem
        Tag = 5
        Caption = '5'
        Checked = True
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N101: TMenuItem
        Tag = 10
        Caption = '10'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N201: TMenuItem
        Tag = 20
        Caption = '20'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N501: TMenuItem
        Tag = 50
        Caption = '50'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N1001: TMenuItem
        Tag = 100
        Caption = '100'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N2001: TMenuItem
        Tag = 200
        Caption = '200'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
      object N5001: TMenuItem
        Tag = 500
        Caption = '500'
        GroupIndex = 2
        RadioItem = True
        OnClick = N32x321Click
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object hreadcount1: TMenuItem
      Caption = 'Thread count'
      object N12: TMenuItem
        Tag = 1
        Caption = '1'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N22: TMenuItem
        Tag = 2
        Caption = '2'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N31: TMenuItem
        Tag = 3
        Caption = '3'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N41: TMenuItem
        Tag = 4
        Caption = '4'
        Checked = True
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N61: TMenuItem
        Tag = 6
        Caption = '6'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N81: TMenuItem
        Tag = 8
        Caption = '8'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
      object N161: TMenuItem
        Tag = 16
        Caption = '16'
        GroupIndex = 3
        RadioItem = True
        OnClick = N32x321Click
      end
    end
  end
  object SaveDlg: TSaveDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmap file (.bmp)|*.bmp*'
    Title = 'Save raytraced image'
    Left = 136
    Top = 64
  end
  object RenderTimer: TTimer
    Interval = 17
    OnTimer = RenderTimerTimer
    Left = 104
    Top = 64
  end
end