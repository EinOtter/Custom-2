--Serziel, Watcher of the Evil Eye
--Scripted by ChatGPT
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)

    --Search Evil Eye Spell/Trap on summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --Banish 1 Evil Eye S/T in GY to draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    --Gain ATK and protection while controlling Evil Eye of Selene
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetCondition(s.cond)
    e3:SetValue(500)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

-- Link Material filter
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_EVIL_EYE) and c:IsLevelBelow(4)
end
-- Check summon condition for search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Search Evil Eye Spell/Trap
function s.thfilter(c)
    return c:IsSetCard(SET_EVIL_EYE) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
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

-- Banish Evil Eye S/T from GY to draw
function s.drfilter(c)
    return c:IsSetCard(SET_EVIL_EYE) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

-- Check if Evil Eye of Selene is on the field
function s.cond(e)
    return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,44133040)
end