--Sky Striker Ace - Raye Assault Mode
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsMonster),2,2,s.matcheck)
    
    --Destroy opponent's cards + gain ATK
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --Tag out into another Sky Striker Ace (Quick Effect)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Check material includes Raye
function s.matcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsCode,1,nil,26077387) -- 26077387 is "Sky Striker Ace - Raye"
end

-- e1: Destroy opponent's cards
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(s.spellfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.spellfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    local ct=Duel.Destroy(g,REASON_EFFECT)
    if ct>0 and e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() then
        local atk=ct*200
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- e2: Quick Special Summon from Extra Deck
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if sc then
        Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end