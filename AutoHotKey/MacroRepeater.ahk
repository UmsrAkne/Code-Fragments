#Requires AutoHotkey v2.0

; ======= 設定 =======
TotalCount := 5
DelayMs := 2000

; ======= 状態管理 =======
running := false
cancelToken := false
currentCount := 0 ; 現在の実行回数を管理

; ======= GUI カウンター =======
counterGui := Gui("+AlwaysOnTop")
counterGui.OnEvent("Close", (*) => ExitApp())
counterGui.Add("Text",, "実行回数:")
counterGui.Add("Edit", "vTotalCountEdit w60 Number", TotalCount)
counterGui.Add("UpDown", "Range1-3000") ; 1-3000回まで
counterGui.Add("Text", "vCountText w200 h30", "実行回数: 0 / " TotalCount)

counterGui.Title := "進捗カウンター"
counterGui.Show("x100 y100")

; ======= メイン処理関数 (SetTimerから呼び出される) =======
DoAction() {
    global running, cancelToken, currentCount, TotalCount, DelayMs, counterGui

    ; 中断チェック
    if cancelToken {
        SetTimer(DoAction, 0) ; タイマーを即座に停止
        running := false
        ToolTip("キャンセルされました")
        Sleep(1000)
        ToolTip()
        currentCount := 0
        counterGui["CountText"].Text := "実行回数: 0 / " counterGui["TotalCountEdit"].Value
        return
    }

    currentCount++

    ; 処理の実行
	; 一連のメイン処理が走っている間はスレッドがブロックされる
	; そのため、キャンセルリクエストは受け付けない。
    counterGui["CountText"].Text := "実行回数: " currentCount " / " counterGui["TotalCountEdit"].Value

    Sleep(1900)
	Send("!{PrintScreen}")
    Sleep(600)
    Click("left")

    ; 完了チェック
    if (currentCount >= counterGui["TotalCountEdit"].Value) {
        SetTimer(DoAction, 0) ; タイマーを停止
        running := false
        ToolTip("完了！")
        Sleep(1000)
        ToolTip()
        currentCount := 0
        return
    }

    ; 次の実行のためにタイマーを再設定 (SetTimerの呼び出しはメインスレッドをブロックしない)
	; このため、次の実行までの間は処理の中断が可能。
    SetTimer(DoAction, DelayMs)
}

; ======= トグルキー（Ctrl+Shift+F12） =======
^+F12:: {
    global running, cancelToken, currentCount, DelayMs

    if running {
        ; 実行中の場合は停止を要求
        cancelToken := true
        ToolTip("停止要求中…")
        return
    }

    ; 実行開始
    running := true
    cancelToken := false
    currentCount := 0 ; カウンターをリセット
    ToolTip("") ; ツールチップ消去

    ; 処理を SetTimer で開始
    ; DelayMs後にDoActionが初めて実行され、その後DoAction内で自身を再設定する
    SetTimer(DoAction, DelayMs)
}

; ======= 終了処理（Escキー） =======
Esc:: {
    global running
    if running {
        ; 実行中の場合はタイマーを停止してから終了
        SetTimer(DoAction, 0)
    }
    counterGui.Destroy()
    ExitApp
}
