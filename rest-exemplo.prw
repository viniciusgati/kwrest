#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL MeuRest DESCRIPTION "Exemplo de Rest Manual"

WSDATA id  AS STRING OPTIONAL

WSMETHOD GET         DESCRIPTION "Retorna a lista de tarefas" PATH "/tasks"      PRODUCES APPLICATION_JSON
WSMETHOD GET GetById DESCRIPTION "Retorna uma tarefa"         PATH "/tasks/{id}" PRODUCES APPLICATION_JSON
WSMETHOD PUT         DESCRIPTION "Atualiza uma tarefa"        PATH "/tasks/{id}" PRODUCES APPLICATION_JSON
WSMETHOD POST        DESCRIPTION "Cria uma tarefa"            PATH "/tasks"      PRODUCES APPLICATION_JSON
WSMETHOD DELETE      DESCRIPTION "Exclui uma tarefa"          PATH "/tasks/{id}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET WSSERVICE MeuRest
    Local lPost     := .T.
	Local oResponse := JsonObject():New()
	Local aTarefas  := {}
    Local aTasks    := {}

	::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery := " SELECT "
    cQuery += "    ZZZ.ZZZ_CODIGO, "
    cQuery += "    ZZZ.ZZZ_DESC "
    cQuery += " FROM " + RetSqlName("ZZZ") + " ZZZ "
    cQuery += " WHERE "
    cQuery += "        ZZZ.ZZZ_FILIAL   = '" + xFilial("ZZZ") + "' "
    cQuery += "    AND ZZZ.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)

    If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())
            oTask := JsonObject():New()
            oTask['code'] := (cAlias)->ZZZ_CODIGO
            oTask['description'] := (cAlias)->ZZZ_DESC
            AAdd(aTasks, oTask)
            (cAlias)->(DbSkip())
        End
        cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
        ::SetResponse(cResponse)

    Else 
        cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost


WSMETHOD GET GetById PATHPARAM id WSSERVICE MeuRest
	Local lPost    := .T.
	Local oResponse := JsonObject():New()

	Local aTarefas := {}

	::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery := " SELECT "
    cQuery += "    ZZZ.ZZZ_CODIGO, "
    cQuery += "    ZZZ.ZZZ_DESC "
    cQuery += " FROM " + RetSqlName("ZZZ") + " ZZZ "
    cQuery += " WHERE "
    cQuery += "        ZZZ.ZZZ_FILIAL   = '" + xFilial("ZZZ") + "' "
    cQuery += "    AND ZZZ.ZZZ_CODIGO = '" + ::id + "'
	cQuery += "    AND ZZZ.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)

    If (cAlias)->(!Eof())
        lPost := .T.
        oResponse['code'] := (cAlias)->ZZZ_CODIGO
        oResponse['description'] := (cAlias)->ZZZ_DESC

        cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
        ::SetResponse(cResponse)
    Else 
        lPost := .F.
        cRetorno := "Not found"
        SetRestFault(404, cRetorno)
    EndIf

    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD PUT PATHPARAM id WSREST MeuRest
    Local cTarefa   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("CADASTRO")
    Local oRequest  := JsonObject():New()

	::SetContentType("application/json")

    If ZZZ->(DbSeek(XFilial("ZZZ") + cTarefa))

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
        oRequest:fromJson(::GetContent())

        oModel:GetModel('MASTER'):SetValue("ZZZ_DESC", oRequest["description"])

        If (oModel:VldData() .and. oModel:CommitData())
            lPost := .T.
            oResponse['sucess'] := .T.
            cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
            ::SetResponse(cResponse)
        Else
            lPost := .F.
            aError := oModel:GetErrorMessage()
			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
            SetRestFault(400, cRetorno)
        EndIf

        oModel:DeActivate()
    Else
        SetRestFault(400, "Tarefa n�o localizada")
    EndIf

Return lPost

/** Cria uma tarefa
 */
WSMETHOD POST WSREST MeuRest

    Local cTarefa   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("CADASTRO")
    Local oRequest  := JsonObject():New()

	::SetContentType("application/json")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    oRequest:fromJson(::GetContent())

    oModel:GetModel('MASTER'):SetValue("ZZZ_DESC", oRequest["description"])

    If (oModel:VldData() .and. oModel:CommitData())
        lPost := .T.
        ::SetResponse(oModel:GetJsonData())
    Else
        lPost := .F.
        aError := oModel:GetErrorMessage()
        cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
        SetRestFault(400, cRetorno)
    EndIf

    oModel:DeActivate()

Return lPost

/** Deleta uma tarefa
 */
WSMETHOD DELETE PATHPARAM id WSREST MeuRest

    Local cTarefa   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("CADASTRO")

    ::SetContentType("application/json")

    If ZZZ->(DbSeek(XFilial("ZZZ") + cTarefa))

        oModel:SetOperation(MODEL_OPERATION_DELETE)
		oModel:Activate()

        If (oModel:VldData() .and. oModel:CommitData())
            lPost := .T.
            oResponse['sucess'] := .T.
            cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
            ::SetResponse(cResponse)
        Else
            lPost := .F.
            aError := oModel:GetErrorMessage()
			cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
            SetRestFault(400, cRetorno)
        EndIf

        oModel:DeActivate()
    Else
        SetRestFault(400, "Tarefa n�o localizada")
    EndIf

Return lPost



