$PBExportHeader$n_cst_dashboard_ventas.sru
forward
global type n_cst_dashboard_ventas from n_cst_dashboard
end type
type str_tarjetas from structure within n_cst_dashboard_ventas
end type
end forward

type str_tarjetas from structure
	long		ll_proformas
	decimal		ld_proformas
	long		ll_pedidos
	decimal		ld_pedidos
	long		ll_albaranes
	decimal		ld_albaranes
	long		ll_facturas
	decimal		ld_facturas
	decimal		ld_facturas_ant
end type

global type n_cst_dashboard_ventas from n_cst_dashboard
end type

type variables
end variables

forward prototypes
private function any of_array_string_importes (string as_empresa, string as_anyo)
private function any of_datos_tarjetas (string as_empresa, string as_anyo)
public subroutine of_open_sheet (string as_menu_name)
public function string of_get_html ()
end prototypes

private function any of_array_string_importes (string as_empresa, string as_anyo);string ls_select
nvo_ds_api lds_sum
long ll_rowcount, ll_row, ll_findrow
integer li_mes
string ls_importes[]

ls_select = "	SELECT month(fecha_factura) as mes, SUM(subtotal) as importe FROM venfac " + &
			"	WHERE empresa = '" + as_empresa + "' AND situacion = 'S' AND " + &
			"	      anyo = " + as_anyo + " " + &
			"	GROUP BY month(fecha_factura)"   
			
lds_sum = CREATE nvo_ds_api
ll_rowcount = lds_sum.of_cargar(ls_select)

for li_mes = 1 to 12
	ll_findrow = lds_sum.find("mes=" + trim(string(li_mes)), 1, ll_rowcount) 
	if ll_findrow <> 0 then
		ls_importes[li_mes] = string(lds_sum.object.importe[ll_findrow])
	else
		ls_importes[li_mes] = "0"
	end if
next

destroy lds_sum

return ls_importes[]
end function

private function any of_datos_tarjetas (string as_empresa, string as_anyo);str_tarjetas lstr_t
n_cst_sqlexecutor ln_exec
String ls_sql
Any la_values[]
any la_result[]

// Datos simulados para presupuestos
lstr_t.ll_proformas = 25
lstr_t.ld_proformas = 45750.80

// Datos simulados para pedidos
lstr_t.ll_pedidos = 12  
lstr_t.ld_pedidos = 28500.45

// Datos simulados para albaranes
lstr_t.ll_albaranes = 8
lstr_t.ld_albaranes = 15200.30

// Datos reales para facturas
ln_exec = Create n_cst_sqlexecutor
	
ls_sql = "SELECT Sum(subtotal), Count(1) "+&
"FROM venfac "+&
"WHERE empresa = @empresa "+&
"AND anyo = @anyo "

la_values[1] = as_empresa
la_values[2] = as_anyo

la_result[] = ln_exec.of_SelectInto(ls_sql, la_values[])

lstr_t.ld_facturas = Dec(la_result[1])
lstr_t.ll_facturas = Long(la_result[2])
Destroy ln_exec

if isnull(lstr_t.ll_facturas) then lstr_t.ll_facturas = 0
if isnull(lstr_t.ld_facturas) then lstr_t.ld_facturas = 0

return lstr_t
end function

public subroutine of_open_sheet (string as_menu_name);choose case as_menu_name
	case "m_imprimirfacturasventas"
		OpenSheet(w_con_facturas, w_frame, 0, Layered!)
		w_con_facturas.dp_1.value=Datetime(Date("01-01-"+string(year(today()))))
		w_con_facturas.dp_2.value=Datetime(Date("31-12-"+string(year(today()))))
		w_con_facturas.sle_serie.text=""
		w_con_facturas.cb_consultar.triggerevent(Clicked!)
	case else
		messagebox("Dashboard Demo", as_menu_name)
end choose
end subroutine

public function string of_get_html ();string ls_html
string ls_importes_actual[], ls_importes_anterior[]
string ls_meses[] 
str_tarjetas lstr_t
string ls_anyo_actual, ls_anyo_anterior
integer li_idx
String ls_empresa="1"

ls_anyo_actual = string(year(today()))
ls_anyo_anterior = string(year(today()) - 1)

lstr_t = of_datos_tarjetas(ls_empresa, ls_anyo_actual)

//Vaciar Tarjetas:
istr_card = istr_card_vaciar
istr_chart = istr_chart_vaciar
istr_config = istr_config_vaciar

// =============== CONFIGURAR TARJETAS ===============

// Tarjeta 1: Presupuestos Pendientes
li_idx = upperbound(istr_config.ast_cards[])
li_idx++
istr_card.ls_titulo = "Presupuestos Pendientes"
istr_card.ls_tamano = IS_NORMAL
istr_card.ld_valor_principal = lstr_t.ll_proformas
istr_card.ls_texto_principal = ""
istr_card.ls_unidad_principal = ""
istr_card.li_decimales_principal = 0
istr_card.ld_valor_secundario = lstr_t.ld_proformas
istr_card.ls_texto_secundario = ""
istr_card.ls_unidad_secundario = "€"
istr_card.li_decimales_secundario = 2
istr_card.ls_id_click = ""
istr_config.ast_cards[li_idx] = istr_card

// Tarjeta 2: Pedidos Pendientes
li_idx++
istr_card = istr_card_vaciar
istr_card.ls_titulo = "Pedidos Pendientes"
istr_card.ls_tamano = IS_NORMAL
istr_card.ld_valor_principal = lstr_t.ll_pedidos
istr_card.ls_texto_principal = ""
istr_card.ls_unidad_principal = ""
istr_card.li_decimales_principal = 0
istr_card.ld_valor_secundario = lstr_t.ld_pedidos
istr_card.ls_texto_secundario = ""
istr_card.ls_unidad_secundario = "€"
istr_card.li_decimales_secundario = 2
istr_card.ls_id_click = ""
istr_config.ast_cards[li_idx] = istr_card

// Tarjeta 3: Albaranes sin Facturar
li_idx++
istr_card = istr_card_vaciar
istr_card.ls_titulo = "Albaranes sin Facturar"
istr_card.ls_tamano = IS_NORMAL
istr_card.ld_valor_principal = lstr_t.ll_albaranes
istr_card.ls_texto_principal = ""
istr_card.ls_unidad_principal = ""
istr_card.li_decimales_principal = 0
istr_card.ld_valor_secundario = lstr_t.ld_albaranes
istr_card.ls_texto_secundario = ""
istr_card.ls_unidad_secundario = "€"
istr_card.li_decimales_secundario = 2
istr_card.ls_id_click = ""
istr_config.ast_cards[li_idx] = istr_card

// Tarjeta 4: Facturas Emitidas (con click)
li_idx++
istr_card = istr_card_vaciar
istr_card.ls_titulo = "Facturas Emitidas"
istr_card.ls_tamano = IS_NORMAL
istr_card.ld_valor_principal = lstr_t.ll_facturas
istr_card.ls_texto_principal = ""
istr_card.ls_unidad_principal = ""
istr_card.li_decimales_principal = 0
istr_card.ld_valor_secundario = lstr_t.ld_facturas
istr_card.ls_texto_secundario = ""
istr_card.ls_unidad_secundario = "€"
istr_card.li_decimales_secundario = 2
istr_card.ls_id_click = "m_imprimirfacturasventas"
istr_config.ast_cards[li_idx] = istr_card

// =============== CONFIGURAR GRÁFICO ===============

ls_meses = {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"}
ls_importes_actual = of_array_string_importes(ls_empresa, ls_anyo_actual)
ls_importes_anterior = of_array_string_importes(ls_empresa, ls_anyo_anterior)

li_idx = upperbound(istr_config.ast_charts[])
li_idx++
istr_chart.ls_titulo = "FACTURACIÓN MENSUAL " + ls_anyo_anterior + " vs " + ls_anyo_actual
istr_chart.ls_chart_type = IS_BAR
istr_chart.ls_tamano = IS_COMPLETO
istr_chart.ls_etiquetas_x = ls_meses
istr_chart.ls_valores = ls_importes_actual
istr_chart.ls_valores_serie2 = ls_importes_anterior
istr_chart.ls_label_serie1 = ls_anyo_actual
istr_chart.ls_label_serie2 = ls_anyo_anterior
istr_chart.ls_unidad_y = "€"
istr_chart.ls_formato_y = "0"
istr_config.ast_charts[li_idx] = istr_chart

ls_html = of_generar_dashboard_html(istr_config)

return ls_html

end function

on n_cst_dashboard_ventas.create
call super::create
end on

on n_cst_dashboard_ventas.destroy
call super::destroy
end on

