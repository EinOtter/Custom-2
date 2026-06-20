--Sky Striker Ace - Hikaru
local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER_ACE),2,2,s.lcheck)

    -- On Summon: Add 1 Sky Striker Ace monster, then destroy a monster if 3+ Spells in GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.sumcon)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)

    -- Quick Effect: Tribute to Special Summon another Sky Striker Ace Link with different Attribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Link material check (must include Sky Striker Ace)
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,SET_SKY_STRIKER_ACE)
end

-- Summon condition: must be Link Summoned
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

-- Add Sky Striker Ace monster
function s.thfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsMonster() and c:IsAbleToHand()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- If 3+ Spells in GY, destroy 1 monster on the field
        if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
            local dg=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
            if #dg>0 then
                Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end

-- Quick Effect: Tribute cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Quick Effect: Special Summon from Extra Deck with different Attribute
function s.spfilter(c,e,tp,att)
    return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and c:IsLink(2)
        and not c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local att=e:GetHandler():GetAttribute()
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,att) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetHandler():GetAttribute()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end