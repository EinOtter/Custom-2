--Lady Labrynth of the Crimson Keep
local s,id=GetID()
function s.initial_effect(c)
    --Quick Effect: Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Quick Effect: Set 1 Normal Trap from Deck with a different name
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SET)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    --Once per turn, non-targeting Pop if a Normal Trap is activated
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.popcon)
    e3:SetTarget(s.poptg)
    e3:SetOperation(s.popop)
    c:RegisterEffect(e3)
end

--Quick Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    return rc:IsSetCard(SET_LABRYNTH) or (rc:IsType(TYPE_TRAP) and rc:IsType(TYPE_NORMAL))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Set Normal Trap condition
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    return rc:IsType(TYPE_TRAP) and rc:IsType(TYPE_NORMAL)
        and not Duel.IsDamageCalculated()
end

--Filter for Normal Traps with a different name
function s.setfilter(c,code)
    return c:IsType(TYPE_TRAP) and c:IsType(TYPE_NORMAL) and c:IsSSetable() and c:GetCode()~=code
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,rc:GetCode())
    end
    Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetCode())
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
        Duel.ConfirmCards(1-tp,g)
    end
end

--Pop effect condition: activated when a Normal Trap is activated
function s.popcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsType(TYPE_TRAP) and rc:IsType(TYPE_NORMAL)
        and not Duel.IsDamageCalculated()
end

--Pop effect target: non-targeting
function s.poptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

--Pop effect operation: destroy 1 card on field (non-targeting)
function s.popop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
