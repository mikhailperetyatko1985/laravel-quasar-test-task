<template>
  <div :class="$style.reviewsContainer">
    <div :class="$style.reviewsHeader">
      <div :class="$style.platformBadge">
        <img :src="mapPointerIcon" alt="" :class="$style.mapIcon" />
        <span :class="$style.platformName">Яндекс.Карты</span>
      </div>
    </div>

    <div :class="$style.reviewsContent">
      <div :class="$style.reviewsList">
        <ReviewItem
          v-for="review in reviews"
          :key="review.id"
          :date="review.date"
          :branch="review.branch"
          :rating="review.rating"
          :author="review.author"
          :user-link="review.userLink"
          :phone="review.phone"
          :text="review.text"
        />
      </div>

      <div :class="$style.reviewsSidebar">
        <ReviewRating :rating="overallRating" :total-reviews="totalReviews" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import ReviewRating from './ReviewRating.vue';
import ReviewItem from './ReviewItem.vue';
import mapPointerIcon from 'src/assets/images/map-pointer.svg';

export interface Review {
  id: number | string;
  date: string | Date;
  branch: string;
  rating: number;
  author: string;
  userLink?: string | null;
  phone?: string;
  text: string;
}

interface Props {
  reviews: Review[];
  overallRating: number;
  totalReviews: number;
}

withDefaults(defineProps<Props>(), {
  reviews: () => [],
  overallRating: 0,
  totalReviews: 0
});
</script>

<style module lang="scss">
.reviewsContainer {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.reviewsHeader {
  display: flex;
  align-items: center;
  justify-content: flex-start;
}

.platformBadge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: white;
  padding: 2px;
  border-radius: 8px;
  border: 1px solid #DCE4EA;

  .platformName {
    font-size: 14px;
    font-weight: 600;
    color: #1a1a1a;
  }
}

.mapIcon {
  width: 18px;
  height: 18px;
}

.reviewsContent {
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 24px;
  align-items: start;
}

.reviewsList {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reviewsSidebar {
  position: sticky;
  top: 80px;
}

@media (max-width: 1024px) {
  .reviewsContent {
    grid-template-columns: 1fr;
  }
  
  .reviewsSidebar {
    position: static;
    order: -1;
  }
}
</style>
