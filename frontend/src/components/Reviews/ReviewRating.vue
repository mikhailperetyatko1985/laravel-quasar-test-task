<template>
  <div :class="$style.reviewRatingCard">
    <div :class="$style.ratingSummary">
      <div :class="$style.ratingHeader">
        <div :class="$style.ratingNumber">{{ rating.toFixed(1) }}</div>
        <div :class="$style.ratingStars">
          <q-icon
            v-for="(star, index) in starsArray"
            :key="index"
            :name="star"
            color="orange"
            size="32px"
          />
        </div>
      </div>
      <q-separator />
      <div :class="$style.ratingText">Всего отзывов: {{ totalReviews.toLocaleString() }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

interface Props {
  rating: number;
  totalReviews: number;
}

const props = withDefaults(defineProps<Props>(), {
  rating: 0,
  totalReviews: 0
});

const starsArray = computed(() => {
  const stars = [];
  const fullStars = Math.floor(props.rating);
  const hasHalfStar = props.rating % 1 >= 0.5;
  
  for (let i = 0; i < fullStars; i++) {
    stars.push('star');
  }
  
  if (hasHalfStar) {
    stars.push('star_half');
  }
  
  while (stars.length < 5) {
    stars.push('star_border');
  }
  
  return stars;
});
</script>

<style module lang="scss">
.reviewRatingCard {
  background: white;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid #E0E7EC;
  box-shadow: 0 3px 6px rgba(92, 101, 111, 0.3);
  min-height: 155px;
  display: flex;
  flex-direction: column;
}

.ratingSummary {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.ratingHeader {
  display: flex;
  align-items: center;
  gap: 16px;
}

.ratingNumber {
  font-size: 48px;
  font-weight: 500;
  color: #1a1a1a;
  line-height: 1;
}

.ratingStars {
  display: flex;
  gap: 4px;
  align-items: center;
}

.ratingText {
  font-size: 16px;
  font-weight: 600;
  color: #1a1a1a;
}
</style>
