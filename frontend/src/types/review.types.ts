export interface Review {
  id: number | string;
  date: string | Date;
  branch: string;
  rating: number;
  author: string;
  phone?: string;
  text: string;
}

export interface ReviewsData {
  reviews: Review[];
  overallRating: number;
  totalReviews: number;
}
