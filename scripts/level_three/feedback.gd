extends Node

# Handles analysing player score and giving feedback based on that

onready var feedback_text = $"../report/report_points/ScrollContainer/VBoxContainer/feedback_body/feedback"


# Based on points, gives player something to think about
# in order of importance
func give_feedback(sustainability, difference, sizing, soc):
	var points_array = [sustainability, difference, sizing, soc]
	var lowest_score = points_array.min()
	if lowest_score == sustainability:
		feedback_text.bbcode_text = "Omavaraisuusastetta saat nostettua lisäämällä aurinkokeräinpaneelin pinta-alaa. Omavaraisuusaste on nollaa parempi myös, mikäli varaat akustoon lähtökapasiteettia eli energiaa vuoden alussa."
	elif lowest_score == sizing:
		feedback_text.bbcode_text = "Mitoitus voi tarkoittaa joko järjestelmän ali- tai ylimitoitusta. Jos järjestelmä on alimitoitettu, sähköä joudutaan hankkimaan verkosta tai purkamalla akkuun varastointunutta energiaa. Vastaavasti ylimitoitetussa järjestelmässä ylijäämäsähköä on joko syötettävä verkkoon tai johdettava maahan. Lisää tai vähennä aurinkokeräinpaneelin pinta-alaa tarvittaessa seuraavaan projektiin."
	elif lowest_score == difference:
		feedback_text.bbcode_text = "Tasapaino edellyttää, että aurinkokeräinpaneelia on sopivassa suhteessa vuosikulutukseen ja akustossa on myös oikea määrä lähtökapasiteettia. Muuta näitä tarpeen mukaan seuraavaan projektiin."
	elif lowest_score == soc:
		feedback_text.bbcode_text = "Akkukesto heikkenee, mikäli akusto pääsee liian tyhjäksi. Lisää lähtökapasiteettia tarvittaessa seuraavaan projektiin."
