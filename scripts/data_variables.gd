extends Node

# Variables that are useful in multiple scenes
# Right now that means level 2 and level 3 calculations
# see the excel for these

# this might be randomised
var PV_T_area = 1000 # m2
# these are to be randomised
var PV_hyotysuhde = 0.15
var COP = 5
var akuston_alkuvaraus = 40 # MWh
var akuston_energiahyotysuhde = 0.9
# these are constant
const KERROIN_FR = 0.7
const TAU_ALFA_TULO = 0.85
const HAVIOKERROIN = 1 # W/m2K
const VEDEN_SISAANMENOLAMPOTILA = 25 # C 
