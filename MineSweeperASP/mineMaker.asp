<%
    ' mine에서 ajax통신을 진행해줄 장소이다.
    Dim Xin, Yin, minein
    Dim tableVal
    Dim mineTable
    Dim XFrame(8)
    Dim YFrame(8)
    XFrame(0) = -1
    XFrame(1) = -1
    XFrame(2) = -1
    XFrame(3) = 0
    XFrame(4) = 0
    XFrame(5) = 1
    XFrame(6) = 1
    XFrame(7) = 1
    
    YFrame(0) = -1
    YFrame(1) = 0
    YFrame(2) = 1
    YFrame(3) = -1
    YFrame(4) = 1
    YFrame(5) = -1
    YFrame(6) = 0
    YFrame(7) = 1
    ' post로 보낸 값을 받기 위한 request.Form
    Xin    = request.Form("Xin")
    Yin    = request.Form("Yin")
    minein = request.Form("minein")
    Dim mineVal(20, 50)
    
    mineTable = ""

    ' 0부터 설정한곳까지 0으로 초기화
    For i=0 to Yin-1 step 1
        For j=0 to Xin-1 step 1
            mineVal(i, j) = 0
        next
    Next
    
    ' 랜덤하게 값을 만들어 주고, 만약 이미 지뢰이면 다시 한번 랜덤하게 만들어 준다.
    For i=1 to minein step 1
        mineX = Int(Rnd()* Xin)
        mineY = Int(Rnd()* Yin)
        If mineVal(mineY, mineX) = -1 Then
            i = i-1
        Else
            mineVal(mineY, mineX) = -1
        end if
    Next

    ' 지뢰 주변의 숫자들을 1씩 키워준다.
    For i=0 to Yin-1 step 1
        For j=0 to Xin-1 step 1
            If mineVal(i, j) = -1 Then
                For k=0 to 7 step 1
                    If i+YFrame(k)>=0 AND i+YFrame(k)<Yin AND j+XFrame(k)>=0 AND j+XFrame(k)<Xin Then
                        If mineVal(i+YFrame(k), j+XFrame(k)) <> -1 Then
                            mineVal(i+YFrame(k), j+XFrame(k)) =  mineVal(i+YFrame(k), j+XFrame(k)) + 1
                        End If
                    End If
                Next
            End If
        Next
    next

    ' td tr을 만들고 필요한 값들을 넣어준다. Ajax로 만든 이유는 이렇게 해서 html에 value를 넣으면 디버그 시에 값을 확인하기 어렵도록 하기 위함이다.
    For i=1 to Yin step 1
        mineTable = mineTable & "<tr align='center'>"
        For j=1 to Xin step 1
            mineTable = mineTable & "<td class='location' checker=0 mineVal="& mineVal(i-1, j-1) &" XVal=" & j & " YVal=" & i & " id="&j-1&"aa"&i-1&"  ></td> "
        Next
        mineTable = mineTable & "</tr>"
    Next
     ' 만들어진 값을 보내준다.
     Response.write(mineTable)

%>
