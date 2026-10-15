#!/usr/bin/env python3
"""Build Collocations.json from a curated list, preferring real OEWN example sentences.

Usage: python3 Tools/build_collocations.py <Dictionary.sqlite> <Collocations.json>

Each row: group | phrase | common wrong form (optional) | fallback example.
The hand-written example is always kept. A second example is added from OEWN (CC BY 4.0,
already bundled) only when a full sentence with a clear subject contains the collocation;
OEWN examples are often fragments, so they never replace the hand-written one.
"""
import json
import re
import sqlite3
import sys

ROWS = """
make|make a decision|do a decision|We need to make a decision by Friday.
make|make a mistake|do a mistake|Everyone makes a mistake sometimes.
make|make an effort|do an effort|She made an effort to arrive on time.
make|make progress|do progress|My English is making good progress.
make|make money|do money|He makes money by selling old books.
make|make friends|do friends|It is easy to make friends at a new school.
make|make a noise|do a noise|Please don't make a noise, the baby is asleep.
make|make sense||His explanation doesn't make sense to me.
make|make a choice|do a choice|You have to make a choice between the two jobs.
make|make a mess|do a mess|The children made a mess in the kitchen.
make|make an excuse|do an excuse|He always makes an excuse for being late.
make|make a promise|do a promise|I made a promise to call her every week.
make|make a phone call|do a phone call|Can I make a phone call from here?
make|make a suggestion|do a suggestion|May I make a suggestion?
make|make an appointment|do an appointment|I made an appointment with the dentist.
make|make a difference|do a difference|Small changes can make a big difference.
make|make a plan|do a plan|Let's make a plan for the weekend.
make|make a profit|do a profit|The shop made a profit in its first year.
make|make a complaint|do a complaint|She made a complaint about the noise.
make|make room|do room|Can you make room for one more person?
do|do homework|make homework|I do my homework after dinner.
do|do the housework|make the housework|We share the housework at home.
do|do the dishes|make the dishes|It's your turn to do the dishes.
do|do business|make business|The company does business in many countries.
do|do damage|make damage|The storm did a lot of damage to the roof.
do|do research|make research|She is doing research on climate change.
do|do exercise|make exercise|I try to do some exercise every morning.
do|do your best|make your best|Don't worry about the result, just do your best.
do|do the shopping|make the shopping|I usually do the shopping on Saturdays.
do|do harm|make harm|A little rest never did anyone any harm.
do|do a job|make a job|He did a great job on the report.
do|do a course|make a course|She is doing a course in photography.
do|do someone a favour|make someone a favour|Could you do me a favour and close the window?
take|take a photo|make a photo|Can you take a photo of us?
take|take a break|make a break|Let's take a break for ten minutes.
take|take a shower|make a shower|I take a shower every morning.
take|take a seat|make a seat|Please take a seat; the doctor will see you soon.
take|take a risk|make a risk|Starting a business means taking a risk.
take|take a chance|make a chance|I'll take a chance and apply for the job.
take|take notes||Students take notes during the lecture.
take|take an exam|make an exam|I'm taking an exam next week.
take|take place|make place|The meeting will take place on Monday.
take|take part|make part|Twenty teams took part in the competition.
take|take care|make care|Take care when you cross the road.
take|take time||Learning a language takes time.
take|take advice|make advice|You should take your doctor's advice.
take|take medicine|eat medicine|Take this medicine twice a day.
take|take a look|make a look|Let me take a look at your car.
take|take responsibility|make responsibility|Managers must take responsibility for their teams.
take|take action|make action|The government must take action now.
take|take turns|make turns|The children took turns on the swing.
have|have breakfast||We have breakfast at seven.
have|have a party|make a party|We're having a party on Saturday.
have|have a good time|make a good time|Did you have a good time at the concert?
have|have a rest|make a rest|You look tired, have a rest.
have|have fun||We had fun at the beach.
have|have a problem||I have a problem with my phone.
have|have a chat|make a chat|We had a chat over coffee.
have|have an idea|make an idea|I have an idea for the project.
have|have a dream|make a dream|Last night I had a strange dream.
have|have an argument||They had an argument about money.
have|have a word||Can I have a word with you?
have|have a baby|get a baby|My sister is going to have a baby.
get|get married||They got married last summer.
get|get lost||We got lost in the old part of the city.
get|get ready||Get ready, the taxi is here.
get|get a job||He got a job at a bank.
get|get dressed|get clothed|I got dressed quickly and went out.
get|get home|get to home|What time did you get home?
get|get angry||She gets angry when people are late.
get|get better||I hope you get better soon.
give|give advice|give an advice|My teacher gave me some good advice.
give|give a speech||The president gave a speech on TV.
give|give someone a hand||Can you give me a hand with these boxes?
give|give permission||The school gave permission for the trip.
give|give birth|make birth|She gave birth to a healthy boy.
give|give an example|make an example|Can you give an example?
keep|keep a secret|hold a secret|Can you keep a secret?
keep|keep a promise|hold a promise|He always keeps his promises.
keep|keep calm||Keep calm and wait for help.
keep|keep in touch||Let's keep in touch after the course.
keep|keep a diary||I kept a diary when I was a child.
catch|catch a cold|take a cold|I caught a cold last week.
catch|catch a bus||I catch a bus to work every day.
catch|catch fire|take fire|The old house caught fire.
catch|catch someone's attention||The bright poster caught my attention.
pay|pay attention|give attention|Please pay attention to the instructions.
pay|pay a visit||We paid a visit to our grandparents.
pay|pay a compliment|make a compliment|He paid her a compliment on her dress.
pay|pay the bill||Can we pay the bill, please?
break|break a promise||He broke his promise and didn't come.
break|break the law||Driving too fast is breaking the law.
break|break a record||She broke the world record.
break|break the news||Who will break the news to her?
other verbs|save time||Online shopping saves time.
other verbs|save money||I'm saving money for a new bike.
other verbs|spend time||I spend time with my family at weekends.
other verbs|waste time||Don't waste time on social media.
other verbs|run a business|lead a business|She runs a small business from home.
other verbs|tell the truth|say the truth|Always tell the truth.
other verbs|tell a lie|say a lie|He told a lie about his age.
other verbs|tell a story|say a story|Grandma told us a story before bed.
other verbs|say goodbye|tell goodbye|We said goodbye at the station.
other verbs|say sorry|tell sorry|You should say sorry to your brother.
other verbs|lose weight||He lost weight by walking every day.
other verbs|lose your temper|lose your nerves|Try not to lose your temper.
other verbs|raise money||They raised money for the hospital.
other verbs|raise a question||Her report raises an important question.
other verbs|meet a deadline|reach a deadline|We worked late to meet the deadline.
other verbs|reach an agreement||The two sides reached an agreement.
other verbs|commit a crime|do a crime|He was accused of committing a crime.
other verbs|draw a conclusion|make a conclusion|It's too early to draw a conclusion.
other verbs|hold a meeting|make a meeting|We hold a meeting every Monday.
other verbs|set a goal|put a goal|Set a goal you can reach.
other verbs|solve a problem||We solved the problem together.
other verbs|follow advice||I followed her advice and felt better.
other verbs|ask a question|make a question|Can I ask a question?
adjective + noun|heavy rain|strong rain|Heavy rain flooded the streets.
adjective + noun|heavy traffic|big traffic|We were late because of heavy traffic.
adjective + noun|strong coffee|powerful coffee|I need a cup of strong coffee.
adjective + noun|strong wind|heavy wind|A strong wind blew the tree down.
adjective + noun|light rain|weak rain|There was light rain in the morning.
adjective + noun|high price|expensive price|They paid a high price for the house.
adjective + noun|deep sleep|heavy sleep|She fell into a deep sleep.
adjective + noun|fast food|quick food|Fast food is cheap but not healthy.
adjective + noun|close friend|near friend|Anna is a close friend of mine.
adjective + noun|hard work|heavy work|Success comes from hard work.
adjective + noun|serious problem||Pollution is a serious problem.
adjective + noun|main reason||Cost is the main reason we chose it.
adjective + noun|common sense||Use your common sense.
adjective + noun|wide range|big range|The shop sells a wide range of goods.
adjective + noun|slim chance|thin chance|There is only a slim chance of winning.
adjective + noun|fresh air|new air|Let's go outside for some fresh air.
adjective + noun|sharp pain|strong pain|I felt a sharp pain in my back.
adjective + noun|great success||The concert was a great success.
adjective + noun|bright future||She has a bright future ahead of her.
adjective + noun|bitter cold|strong cold|The bitter cold kept everyone indoors.
adjective + noun|rich food||I can't eat rich food late at night.
adjective + noun|broad smile||He greeted us with a broad smile.
adjective + noun|high speed|big speed|The train travels at high speed.
adjective + noun|best friend||My best friend lives next door.
adjective + noun|large amount|big amount|A large amount of water was wasted.
adverb + adjective|completely different||The two cities are completely different.
adverb + adjective|highly unlikely||It is highly unlikely that it will snow.
adverb + adjective|absolutely sure||Are you absolutely sure?
adverb + adjective|fully aware||I am fully aware of the risks.
adverb + adjective|bitterly disappointed|strongly disappointed|The fans were bitterly disappointed.
adverb + adjective|perfectly normal||It's perfectly normal to feel nervous.
adverb + adjective|seriously ill|heavily ill|He was seriously ill last year.
adverb + adjective|deeply sorry|strongly sorry|I'm deeply sorry for your loss.
adverb + adjective|widely known|largely known|The story is widely known.
adverb + adjective|fast asleep|quickly asleep|The baby is fast asleep.
verb + preposition|depend on|depend of|It depends on the weather.
verb + preposition|rely on|rely in|You can rely on me.
verb + preposition|listen to|listen music|I listen to music on the bus.
verb + preposition|wait for|wait someone|I'm waiting for the bus.
verb + preposition|look after||Can you look after my cat?
verb + preposition|think about|think on|I'm thinking about changing jobs.
verb + preposition|agree with||I agree with you.
verb + preposition|apologise for|apologise about|He apologised for the delay.
verb + preposition|belong to|belong at|This bag belongs to me.
verb + preposition|believe in|believe on|Do you believe in ghosts?
verb + preposition|consist of|consist from|The team consists of five people.
verb + preposition|insist on|insist to|She insisted on paying.
verb + preposition|succeed in|succeed to|He succeeded in passing the test.
verb + preposition|complain about|complain on|They complained about the food.
verb + preposition|worry about|worry for|Don't worry about it.
verb + preposition|deal with|deal about|I'll deal with the problem tomorrow.
verb + preposition|focus on|focus in|Focus on one task at a time.
verb + preposition|apply for|apply a job|She applied for a new job.
verb + preposition|arrive at|arrive to|We arrived at the station early.
verb + preposition|good at|good in|She is good at maths.
noun phrases|a piece of advice|an advice|Let me give you a piece of advice.
noun phrases|a sense of humour|a humour sense|He has a great sense of humour.
noun phrases|a round of applause||Let's give her a round of applause.
noun phrases|a waste of time|a lose of time|That meeting was a waste of time.
noun phrases|a matter of time||It's only a matter of time.
noun phrases|a bar of chocolate||I bought a bar of chocolate.
noun phrases|a means of transport|a transport mean|The bike is my favourite means of transport.
noun phrases|a point of view|a point of sight|From my point of view, it's a good idea.
"""

IRREGULAR = {
    "make": ["made"], "do": ["did", "done", "does"], "take": ["took", "taken"],
    "have": ["has", "had"], "get": ["got", "gotten"], "give": ["gave", "given"],
    "keep": ["kept"], "catch": ["caught"], "pay": ["paid"], "break": ["broke", "broken"],
    "spend": ["spent"], "run": ["ran"], "tell": ["told"], "say": ["said"],
    "lose": ["lost"], "meet": ["met"], "draw": ["drew", "drawn"], "hold": ["held"],
    "set": [], "think": ["thought"],
}
DETERMINER = r"(?:a|an|the|my|your|his|her|its|our|their|some|no)"
SUBJECTS = {"i", "you", "he", "she", "we", "they", "it", "the", "my", "his", "her", "our", "their", "there"}
BLOCKED = {"incest", "kill", "killed", "drunk", "sex", "dowered", "beaut"}
# Reviewed by hand: fragments, shifted meanings, rare words, or typos in the source.
REJECTED = ("grassroots", "dog did a job", "has an idea that", "didacticism", "bareboating",
            "tinctures", "guttered", "along time", "front burner", "waste of time could",
            "persisted", "upset of his sled", "usher", "perturbed", "naive", "puddling",
            "back door", "break even", "in the end")


def verb_forms(verb):
    stem = verb[:-1] if verb.endswith("e") else verb
    forms = {verb, verb + "s", stem + "ing", stem + "ed" if verb.endswith("e") else verb + "ed"}
    if verb.endswith(("ch", "sh")):
        forms.add(verb + "es")
    return forms | set(IRREGULAR.get(verb, []))


def pattern(group, phrase):
    words = phrase.split()
    if words[-1] == "someone's" or "someone" in words:
        return None  # placeholder phrases: keep the hand-written example
    parts = []
    for i, word in enumerate(words):
        if i == 0 and group not in ("adjective + noun", "adverb + adjective", "noun phrases"):
            parts.append("(?:" + "|".join(sorted(map(re.escape, verb_forms(word)))) + ")")
        elif word in ("a", "an", "the", "your"):
            parts.append(DETERMINER + "?")
        elif i == len(words) - 1:
            parts.append(re.escape(word) + "s?")
        else:
            parts.append(re.escape(word))
    body = r"\s*".join(p if p.endswith("?") else p + " " for p in parts).rstrip()
    body = body.replace(" ", r"\s+").replace(r"\s+\s*", r"\s*")
    return re.compile(r"\b" + body + r"\b", re.IGNORECASE)


def oewn_examples(db_path):
    # ponytail: whole-table scan, a few seconds; fine for a build-time tool.
    seen = set()
    for (payload,) in sqlite3.connect(db_path).execute("select payload from entries"):
        for sense in json.loads(payload).get("senses", []):
            for ex in sense.get("examples", []):
                if isinstance(ex, str) and ex not in seen:  # skip quotation objects (album titles, wiki text)
                    seen.add(ex)
                    yield ex


def good_sentence(text):
    words = re.findall(r"[a-z']+", text.lower())
    return (5 <= len(words) <= 14 and words[0] in SUBJECTS
            and not BLOCKED & set(words) and text.count(",") <= 1
            and not any(r in text for r in REJECTED))


def main(db_path, out_path):
    rows = [line.split("|") for line in ROWS.strip().splitlines()]
    candidates = [ex for ex in oewn_examples(db_path) if good_sentence(ex)]
    items, from_oewn = [], 0
    for group, phrase, wrong, fallback in rows:
        regex = pattern(group, phrase)
        hits = sorted((ex for ex in candidates if regex and regex.search(ex)), key=len) if regex else []
        hits = [ex for ex in hits if ex.rstrip(".").lower() != fallback.rstrip(".").lower()]
        item = {"phrase": phrase, "group": group, "example": fallback}
        if wrong:
            item["wrong"] = wrong
        if hits:
            extra = hits[0][0].upper() + hits[0][1:]
            item["example2"] = extra if extra[-1] in ".!?" else extra + "."
            from_oewn += 1
        items.append(item)
    with open(out_path, "w") as f:
        json.dump(items, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"{len(items)} collocations, {from_oewn} with a second example from OEWN")


if __name__ == "__main__":
    main(*sys.argv[1:3])
