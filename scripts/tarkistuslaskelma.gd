extends Node


# Accessing the singleton data scene
onready var data = $"../data_variables"
onready var weather_data = $"../weather_data"
onready var weather_data_dictionary = weather_data.weather_dictionary


func st_lampo(current_solar_collector_area, hour):
	var result = current_solar_collector_area * data.KERROIN_FR * (data.TAU_ALFA_TULO * weather_data_dictionary[hour].SATEILY - data.HAVIOKERROIN * (data.VEDEN_SISAANMENOLAMPOTILA - weather_data_dictionary[hour].ULKOLAMPOTILA))
	if result < 0 or result == -0: # for whatever reason the zero might be negative lol
		result = 0
	return result


func pv_sahko(current_solar_collector_area, hour):
	var result = current_solar_collector_area * data.PV_hyotysuhde * weather_data_dictionary[hour].SATEILY
	return result


func lampoalijaama(st_lampo, hour):
	var result = weather_data_dictionary[hour].LAMMITYS - st_lampo
	if result < 0 or result == -0: # for whatever reason the zero might be negative lol
		result = 0
	return result


func lampopumppu(lampoalijaama):
	var result = 0
	if lampoalijaama > 0:
		result = lampoalijaama / data.COP
	return result


func sahkotot(lampopumppu, hour):
	var result = weather_data_dictionary[hour].SAHKO + lampopumppu
	return result


func sahkoalijaama(sahkotot, pv_sahko):
	var result = 0
	if sahkotot > pv_sahko:
		result = sahkotot - pv_sahko
	return result


func sahkoylijaama(sahkotot, pv_sahko):
	var result = 0
	if pv_sahko > sahkotot:
		result = pv_sahko - sahkotot
	return result


func lataus(sahkoalijaama):
	var result = data.akuston_energiahyotysuhde * sahkoalijaama
	return result

func akku_purku(weather_dict, energy_reserve_cabability_at_start):
	for hour in weather_dict:
		# on first hour
		if hour == 0:
			# purku
			if weather_dict[hour].sahkoalijaama > 0 and 1000000 * energy_reserve_cabability_at_start > 0:
				if 1000000 * energy_reserve_cabability_at_start - weather_dict[hour].sahkoalijaama > 0:
					weather_dict[hour].purku = weather_dict[hour].sahkoalijaama
				else:
					weather_dict[hour].purku = 1000000 * energy_reserve_cabability_at_start
			else:
				weather_dict[hour].purku = energy_reserve_cabability_at_start
			# akku
			weather_dict[hour].akku = 1000000 * energy_reserve_cabability_at_start + weather_dict[hour].lataus - weather_dict[hour].purku
		# on every other hour
		else:
			# purku
			if weather_dict[hour].sahkoalijaama > 0 and weather_dict[hour-1].akku > 0:
				if weather_dict[hour-1].akku - weather_dict[hour].sahkoalijaama > 0:
					weather_dict[hour].purku = weather_dict[hour].sahkoalijaama
				else:
					weather_dict[hour].purku = weather_dict[hour-1].akku
			else:
				weather_dict[hour].purku = 0
			# akku
			if weather_dict[hour-1].akku + weather_dict[hour].lataus - weather_dict[hour].purku > 0:
				weather_dict[hour].akku = weather_dict[hour-1].akku + weather_dict[hour].lataus - weather_dict[hour].purku
			else:
				weather_dict[hour].akku = 0


func nettoalijaama(sahkoalijaama, purku):
	var result = sahkoalijaama - purku
	return result
