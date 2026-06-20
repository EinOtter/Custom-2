--Sky Striker Ace - Kurayami
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER_ACE),2,2,s.lcheck)

    -- Set 1 “Sky Striker” Quick-Play Spell and maybe destroy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id) -- once per turn for this effect
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Tribute to summon different Attribute Sky Striker Ace Link Monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1}) -- once per turn for this effect
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Link material check (must include a "Sky Striker Ace" monster)
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,SET_SKY_STRIKER_ACE)
end

-- Set effect: condition
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

-- Set target
function s.setfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER) and c:IsQuickPlaySpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

-- Set operation
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
        Duel.ConfirmCards(1-tp,g)
        -- If 3+ Spells in GY, destroy 1 Spell/Trap on field
        if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
            local dg=Duel.SelectMatchingCard(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_SZONE,1,1,nil)
            if #dg>0 then
                Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end

-- Tribute cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Special Summon target
function s.spfilter(c,e,tp,att)
    return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and c:IsLink(2)
        and not c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local att=e:GetHandler():GetAttribute()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,att)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetHandler():GetAttribute()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end