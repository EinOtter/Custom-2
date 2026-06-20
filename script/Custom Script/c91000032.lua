--Spright Flash
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.mfilter,2,2)
    
    --Cannot be used as Link Material the turn it's Link Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(1)
    e1:SetCondition(s.limcon)
    c:RegisterEffect(e1)
    
    --ATK Boost to Linked Level/Rank/Link 2 monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(600)
    c:RegisterEffect(e2)
    
    --Quick effect: Special Summon 1 "Spright" from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

--Link Materials: 2 Level 2/Rank 2 monsters
function s.mfilter(c,lc,sumtype,tp)
    return (c:IsLevel(2) or c:IsRank(2)) and c:IsType(TYPE_MONSTER,lc,sumtype,tp)
end

--Cannot be used as Link Material the turn it's Link Summoned
function s.limcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--ATK Boost Target: Linked Level/Rank/Link 2 monsters
function s.atktg(e,c)
    local seq=c:GetSequence()
    local tp=c:GetControler()
    local lc=e:GetHandler()
    return c:IsFaceup() and c:IsControler(tp) and lc:GetLinkedGroup():IsContains(c)
        and (c:IsLevel(2) or c:IsRank(2) or (c:IsType(TYPE_LINK) and c:GetLink()==2))
end

--Main Phase only
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

--Target Spright in GY
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_SPRIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end