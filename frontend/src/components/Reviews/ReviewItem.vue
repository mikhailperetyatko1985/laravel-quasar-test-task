<template>
  <div :class="$style.reviewItemContainer">
    <div :class="$style.reviewItem">
      <div :class="$style.reviewHeader">
        <div :class="$style.reviewMeta">
          <span :class="$style.reviewDate">{{ formattedDate }}</span>
          <div :class="$style.reviewBranch">
            <img :src="mapPointerIcon" alt="" :class="$style.mapIcon" />
            <span>{{ branch }}</span>
          </div>
          </div>
          <div :class="$style.reviewStars">
            <q-icon
              v-for="n in rating"
              :key="n"
              name="star"
              color="orange"
              size="18px"
            />
          </div>
        </div>

        <div :class="$style.reviewAuthorInfo">
          <a
            v-if="userLink"
            :href="userLink"
            target="_blank"
            rel="noopener noreferrer"
            :class="[$style.authorName, $style.authorLink]"
          >
            {{ author }}
          </a>
          <span v-else :class="$style.authorName">{{ author }}</span>
          <span v-if="phone" :class="$style.authorPhone">{{ phone }}</span>
        </div>

        <div :class="$style.reviewText">{{ text }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import mapPointerIcon from 'src/assets/images/map-pointer.svg';

interface Props {
  date: string | Date;
  branch: string;
  rating: number;
  author: string;
  userLink?: string | null;
  phone?: string;
  text: string;
}

const props = withDefaults(defineProps<Props>(), {
  userLink: null,
  phone: ''
});

const formattedDate = computed(() => {
  const date = typeof props.date === 'string' ? new Date(props.date) : props.date;
  
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const year = date.getFullYear();
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  
  return `${day}.${month}.${year} ${hours}:${minutes}`;
});
</script>

<style module lang="scss">
.reviewItemContainer {
  border-radius: 12px;
  padding-left: 16px;
  padding-bottom: 16px;
  padding-top: 16px;
  border: 1px solid #E0E7EC;
  box-shadow: 0 3px 6px rgba(92, 101, 111, 0.3);
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 155px;
}

.reviewItem {
    background: #F6F8FA;
}

.reviewHeader {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.reviewMeta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.reviewDate {
  font-size: 13px;
  font-weight: 600;
  color: #1a1a1a;
}

.reviewBranch {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #1a1a1a;
}

.mapIcon {
  width: 16px;
  height: 16px;
}

.reviewStars {
  display: flex;
  gap: 2px;
  padding-right: 16px;
}

.reviewAuthorInfo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  
  .authorName {
    font-weight: 600;
    color: #1a1a1a;
  }
  
  .authorLink {
    text-decoration: none;
    transition: color 0.2s;
    
    &:hover {
      color: #1976D2;
      text-decoration: underline;
    }
  }
  
  .authorPhone {
    color: #666;
  }
}

.reviewText {
  font-size: 14px;
  line-height: 1.6;
  color: #444;
  padding-right: 16px;
}
</style>
