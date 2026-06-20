--Predaplant Mycotyrant Helix
local s,id=GetID()

function s.initial_effect(c)
	--Search + Place Predator Counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--Quick Fusion Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.fuscon)
	e3:SetCost(s.fuscost)
	e3:SetTarget(s.fustg)
	e3:SetOperation(s.fusop)
	c:RegisterEffect(e3)
end
--Search and Counter Placement
function s.thfilter(c)
    return c:IsSetCard(SET_PREDAP) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.ctfilter(c)
    return c:IsFaceup() and c:IsCanAddCounter(COUNTER_PREDATOR,1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- Check both players’ Monster Zones correctly:
        if Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local tg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
            if #tg>0 then
                tg:GetFirst():AddCounter(COUNTER_PREDATOR,1)
            end
        end
    end
end
--Fusion Condition
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.fusfilter(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(mg,nil,chkf)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local mg2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
		local mg3=Group.CreateGroup()
		if Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
			mg3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
		end
		local allmat=mg1:Clone()
		allmat:Merge(mg2)
		allmat:Merge(mg3)
		return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,allmat,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp)
	local mg2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
	local mg3=Group.CreateGroup()
	if Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		mg3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
	end

	local allmat=mg1:Clone()
	allmat:Merge(mg2)
	allmat:Merge(mg3)

	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp,allmat,chkf)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	local fcheck=aux.FCheckAdditional
	aux.FCheckAdditional=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK)
	local mg=allmat:Filter(Card.IsCanBeFusionMaterial,nil,tc)
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
	aux.FCheckAdditional=fcheck
	if not mat or #mat==0 then return end

	tc:SetMaterial(mat)
	local rg=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_DECK)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
	mat:Sub(rg)
	if #mat>0 then
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	end
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end