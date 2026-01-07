#!/bin/bash
# 진행률 자동 계산 (동적)

TOTAL_TASKS=0
COMPLETED=0

echo "📊 Calculating progress..."

# 각 Phase의 작업 계산
for phase in phases/phase-*/; do
    if [ -f "$phase/progress.md" ]; then
        # 전체 체크박스 개수 (완료 + 미완료)
        PHASE_TOTAL=$(grep -c "- \[" "$phase/progress.md" 2>/dev/null || echo 0)
        # 완료된 체크박스 개수
        PHASE_COMPLETED=$(grep -c "- \[x\]" "$phase/progress.md" 2>/dev/null || echo 0)
        
        TOTAL_TASKS=$((TOTAL_TASKS + PHASE_TOTAL))
        COMPLETED=$((COMPLETED + PHASE_COMPLETED))
        
        echo "  $(basename $phase): $PHASE_COMPLETED/$PHASE_TOTAL tasks completed"
    fi
done

# 0으로 나누기 방지
if [ "$TOTAL_TASKS" -eq 0 ]; then
    PERCENTAGE=0
else
    PERCENTAGE=$((COMPLETED * 100 / TOTAL_TASKS))
fi

echo ""
echo "📈 Overall Progress: $COMPLETED/$TOTAL_TASKS ($PERCENTAGE%)"

# README.md의 뱃지 업데이트
if [ "$PERCENTAGE" -lt 25 ]; then
    COLOR="red"
elif [ "$PERCENTAGE" -lt 75 ]; then
    COLOR="orange"  
else
    COLOR="green"
fi

# macOS와 Linux 호환성을 위한 sed 명령어
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/Progress-[0-9]*%25-[a-z]*/Progress-$PERCENTAGE%25-$COLOR/" README.md
else
    sed -i "s/Progress-[0-9]*%25-[a-z]*/Progress-$PERCENTAGE%25-$COLOR/" README.md
fi

echo "✅ Progress badge updated in README.md"
