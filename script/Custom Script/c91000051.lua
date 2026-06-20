--DAL Custom Card
local s,id=GetID()
function s.initial_effect(c)
    Duel.LoadScript("BanyspyAux.lua")
    --Effect 1: Special Summon trigger (banish opponent monster + add Level 3 DAL)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.sscon)
    e1:SetTarget(s.sstg)
    e1:SetOperation(s.ssop)
    c:RegisterEffect(e1)
    
    --Effect 2: Quick Effect negate Spell/Trap activation
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end
s.listed_names={id, CARD_DALSPIRIT_ZODIAC}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--Filter: Level 3 DAL monsters
function s.dalfilter(c)
    return c:IsSetCard(SET_DAL) and c:IsLevel(3) and c:IsAbleToHand()
end

--Effect 1 condition: Special Summoned by a "DAL" card
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(SET_DAL)
end

--Effect 1 target
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(s.dalfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

--Effect 1 operation
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.dalfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end

--Effect 2 condition: opponent activates Spell/Trap
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and (re:IsActiveType(TYPE_SPELL)) and Duel.IsChainNegatable(ev)
end

--Effect 2 target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end

--Effect 2 operation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Remove(re:GetHandler(),POS_FACEUP,REASON_EFFECT)
    end
end
