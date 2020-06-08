/datum/random_event/major/player_spawn/pests
	name = "Pests (playable)"

	required_elapsed_round_time = 5 MINUTES

	var/ghost_confirmation_delay = 1 MINUTES // time to acknowledge or deny respawn offer.
	var/list/pest_invasion_critter_types = list(\
	list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,),\
	list(/mob/living/critter/small_animal/cat/weak,),\
	list(/mob/living/critter/small_animal/dog/pug/weak,/mob/living/critter/small_animal/dog/corgi/weak,/mob/living/critter/small_animal/dog/shiba/weak),\
	list(/mob/living/critter/changeling/eyespider,/mob/living/critter/changeling/buttcrab),\
	list(/mob/living/critter/small_animal/frog/weak),\
	list(/mob/living/critter/small_animal/cockroach/robo/weak),)




	event_effect()
		..()

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a random pest? (special ghost critter)") // Don't disclose which type it is. You know, metagaming.
		text_messages.Add("You are eligible to be respawned as a random pest. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of pests. Please wait...")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 0)


		if (candidates.len)
			var/list/EV = list()
			for(var/obj/landmark/S in landmarks)
				if (S.name == "peststart")
					EV.Add(S.loc)
				LAGCHECK(LAG_HIGH)


			EV += (clownstart + monkeystart + blobstart + kudzustart)

			if(!EV.len)
				EV += latejoin
				if (!EV.len)
					message_admins("Pests event couldn't find a pest landmark!")
					return

			var/atom/pestlandmark = pick(EV)

			var/list/select = pick(pest_invasion_critter_types)
			for (var/datum/mind/M in candidates)
				if (M.current)
					M.current.make_ghost_critter(pestlandmark,select)

			pestlandmark.visible_message("A group of pests emerge from their hidey-hole!")

			if (candidates.len >= 5)
				command_alert("A large number of pests have been detected onboard.", "Pest invasion")

