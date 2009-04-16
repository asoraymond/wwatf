
Private Sub Worksheet_Activate()
    old_addr = ActiveCell.Address
    fill_sheetsname 200   '################################### you can change it , 每个子用例定义工作表中的
    Range(old_addr).Select
End Sub

Private Sub Worksheet_Change(ByVal Target As Range)
    addr = Target.Address
    If Mid(Target.Address, 1, 3) = "$C$" Then
        step_addr = Replace(addr, "C", "D")
'        MsgBox Target.Value
        testcase_range = "=" & Target.Value & "!$A$5:$A$200"
        Range(step_addr).Select
'        MsgBox Target.Value & " " & step_addr
        set_selectionlist ("=" & Target.Value & "a5a200")
    End If
    If Mid(Target.Address, 1, 3) = "$D$" Then
        sheet_addr = Replace(addr, "D", "C")
        comment_addr = Replace(addr, "D", "E")
        Comment = ""
        sheet_name = Range(sheet_addr).Value
        max_step_row = 200  '#################################you can change it ,每个测试步骤定义工作表中允许的测试步骤的最大值
        For i = 4 To max_step_row
            s = Worksheets(sheet_name).Cells(i, "A").Value
            If Target.Value = Worksheets(sheet_name).Cells(i, "A").Value Then
                   Comment = Worksheets(sheet_name).Cells(i, "B").Value
                   Exit For
            End If
        Next
        Range(comment_addr).Value = Comment
' get_comment(Range(sheet_addr).Value, Target.Value)
    End If
End Sub


Private Sub fill_sheetcolumn(valuerange As Variant, num As Single)
      For i = 2 To num
          s = "C" & i
          Range(s).Select
          set_selectionlist valuerange
      Next i
End Sub

Private Sub fill_sheetsname(num As Single)
        Columns("J").Clear
        n = 1
        For Each sht In Sheets
            ' s = Left(sht.Name, 1)
            If Worksheets(sht.Name).Cells(1, "A").Value = "startPoint" Then
                Cells(n, "J") = sht.Name
                n = n + 1
                ActiveWorkbook.Names.Add Name:=sht.Name & "a5a200", RefersToR1C1:="=" & sht.Name & "!R5C1:R200C1"
            End If
        Next
        testflow_sheet_range = "=$J$1:$J$" & (n - 1)
        fill_sheetcolumn testflow_sheet_range, num
End Sub

Private Sub set_selectionlist(valuerange)
    rang = valuerange
    With Selection.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
        xlBetween, Formula1:=rang
        .IgnoreBlank = True
        .InCellDropdown = True
        .InputTitle = ""
        .ErrorTitle = ""
        .InputMessage = ""
        .ErrorMessage = ""
        .IMEMode = xlIMEModeNoControl
        .ShowInput = True
        .ShowError = True
    End With
End Sub



