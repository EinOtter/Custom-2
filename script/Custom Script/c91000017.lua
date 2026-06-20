--Psy-Frame Conduit
local s,id=GetID()
function s.initial_effect(c)
    --Activate from hand
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    c:RegisterEffect(e0)

    --Main Effect: Banish 2 Psychic monsters with different names, Summon Lambda
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Condition to activate from hand
function s.handcon(e)
    return Duel.CheckLPCost(e:GetHandlerPlayer(),2000)
end

-- Cost for activating from hand
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        if chk==0 then return Duel.CheckLPCost(tp,2000) end
        Duel.PayLPCost(tp,2000)
    end
end

-- Filter for Psychic monsters that can be banished
function s.rmfilter(c)
    return c:IsRace(RACE_PSYCHIC) and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil)
        return g:GetClassCount(Card.GetCode) >= 2
            and Duel.GetLocationCountFromEx(tp) > 0
            and Duel.IsExistingMatchingCard(s.lambdafilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lambdafilter(c,e,tp)
    return c:IsCode(08802510) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode) < 2 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg1=g:Select(tp,1,1,nil)
    g:Remove(Card.IsCode,nil,sg1:GetFirst():GetCode())

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg2=g:Select(tp,1,1,nil)

    local sg=sg1 + sg2
    if #sg<2 then return end
    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)

    -- Check if only Psy-Frame monsters were banished
    local onlyPsyFrame=sg:FilterCount(function(c) return c:IsSetCard(SET_PSY_FRAME) end,nil)==2

    -- Special Summon Lambda
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local lambda=Duel.SelectMatchingCard(tp,s.lambdafilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if lambda and Duel.SpecialSummon(lambda,0,tp,tp,false,false,POS_FACEUP)>0 and onlyPsyFrame and e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND)==false then
        Duel.Recover(tp,1500,REASON_EFFECT)
    end
end