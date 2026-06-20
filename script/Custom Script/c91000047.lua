--Spirit-Phantom 
local s,id=GetID()
function s.initial_effect(c)
    Duel.LoadScript("BanyspyAux.lua")

    --Special Summon effect on being Special Summoned by a "DAL" card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Quick Effect: Negate activation
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

s.listed_names={id, CARD_DALSPIRIT_PHANTOM}
s.listed_series={SET_DAL,SET_DALSPIRIT}

--Filter for Level 3 "DAL" monsters
function s.dalfilter(c)
    return c:IsLevel(3) and c:IsSetCard(SET_DAL) and c:IsAbleToDeck()
end

--Filter for Special Summonable Spirits
function s.spfilter(c,e,tp)
    local list={
        655368164,655368166,655368168,655368170,655368172,
        655368174,655368176,655368178,655368180,655368182,
        655368184,655368186,91000050
    }
    for _,code in ipairs(list) do
        if c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
            return true
        end
    end
    return false
end

--Condition: Special Summoned by a "DAL" card
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(SET_DAL)
end

--Target (fixed: no longer blocks resolution if Spirit can't be summoned)
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.dalfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

--Operation (fixed: search always resolves)
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.dalfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end

    --Special Summon (optional)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end

    --Search (always happens)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local th=Duel.SelectMatchingCard(tp,s.dalfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #th>0 then
        Duel.SendtoHand(th,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,th)
    end
end

--Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end
