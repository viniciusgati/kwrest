#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH USER MODEL REST NAME Tarefas

/*/{Protheus.doc} TAREFAS
Fonte de Exemplo de Simples de MVC
/*/

User Function TAREFAS()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('ZZZ')
	oBrowse:SetDescription('Browse Customizado')
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.TAREFAS' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.TAREFAS' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.TAREFAS' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.TAREFAS' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir' 	Action 'VIEWDEF.TAREFAS' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'		Action 'VIEWDEF.TAREFAS' OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef()

	Local oStruMod 	:= FWFormStruct(1,'ZZZ')
	Local oModel 	:= MPFormModel():New('M0900101')//Model  8 caracteres

	oModel:AddFields('MASTER',, oStruMod)
	oModel:SetPrimaryKey({'ZZZ_FILIAL', 'ZZZ_CODIGO'})
	oModel:SetDescription('Browse Customizado')
	oModel:GetModel('MASTER'):SetDescription('Browse Customizado')

Return oModel

Static Function ViewDef()

	Local oModel 	:= FWLoadModel('TAREFAS')
	Local oStruView := FWFormStruct(2,'ZZZ')
	Local oView 	:= FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW', oStruView, 'MASTER')
	oView:CreateHorizontalBox('SUPERIOR', 100 )
	oView:SetOwnerView('VIEW', 'SUPERIOR')

Return oView