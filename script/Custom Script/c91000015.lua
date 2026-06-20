-- Wattchronos Falcon (Revised)
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_WATT),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    
    -- Can attack directly
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e1)
    
    -- Banish 1 card from opponent's hand (random), field or GY when inflicts battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.rmcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
    
    -- Special summon 1 level 4 or lower "Watt" monster from GY if destroyed by battle or card effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Condition for banish effect: must control another "Watt" monster
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.IsExistingMatchingCard(s.wattfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end

-- Filter for "Watt" monsters you control (excluding self)
function s.wattfilter(c)
    return c:IsSetCard(0x10f) and c:IsFaceup()
end

-- Target function: opponent has at least one card in hand, field, or GY
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

-- Operation: randomly banish 1 card from opponent’s hand, field, or GY
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
    local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_ONFIELD,0,nil)
    local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_GRAVE,0,nil)
    local tg=Group.CreateGroup()
    tg:Merge(g1)
    tg:Merge(g2)
    tg:Merge(g3)
    if #tg==0 then return end
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
    local sg=tg:RandomSelect(1-tp,1)
    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end

-- Condition for Special Summon: destroyed by battle or card effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and (r&REASON_BATTLE+REASON_EFFECT)~=0
end

-- Filter for special summon target: "Watt" monster level 4 or lower in GY
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_WATT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Operation special summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end