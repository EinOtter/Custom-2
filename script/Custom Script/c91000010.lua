local s,id=GetID()
function s.initial_effect(c)
	--Banish from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)

	--Special Summon itself after being banished
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.selfspcond)
	e4:SetTarget(s.selfsptg)
	e4:SetOperation(s.selfspop)
	c:RegisterEffect(e4)

	--Synchro Summon during the opponent's Main Phase
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.syncsumcond)
	e5:SetTarget(s.syncsumtg)
	e5:SetOperation(s.syncsumop)
	c:RegisterEffect(e5)
end

--Banish filter
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_GHOTI) and c:IsAbleToRemove() and not c:IsCode(id)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--Self Special Summon condition
function s.selfspcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

--Synchro condition
function s.syncsumcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end

function s.syncmfilter(c)
	return c:IsRace(RACE_FISH) and c:IsSynchroSummonable(nil)
end

function s.syncsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.syncmfilter,tp,LOCATION_EXTRA,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.syncsumop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.syncmfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local sc=g:GetFirst()
	if sc then
		Duel.SynchroSummon(tp,sc,nil)
	end
end
