export interface Generation {
  id: string
  content: string
  type: 'image' | 'text'
  elo_rating: number
  created_at: string
}

export interface Vote {
  id: string
  winner_id: string
  loser_id: string
  created_at: string
}
