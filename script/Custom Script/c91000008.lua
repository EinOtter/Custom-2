--Superheavy Samurai Gear Braver
--Scripted by ChatGPT
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    Link.AddProcedure(c,s.mfilter,1,1)
    
    --Special Summon from hand or GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Tribute to search
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Link Material Filter
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_SUPERHEAVY_SAMURAI) 
end

-- Condition: You control no Spells/Traps
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end

-- Target: Special Summon from hand or GY
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_SUPERHEAVY_SAMURAI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
            -- Negate its effects
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2,true)
        end
    end
end

-- Tribute cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Search target
function s.thfilter(c)
    return (c:IsSetCard(SET_SUPERHEAVY_SAMURAI) and c:IsAbleToHand()) or (c:IsCode(SET_SUPERHEAVY_SAMURAI_SOUL) and c:IsAbleToHand())
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
    end
end
