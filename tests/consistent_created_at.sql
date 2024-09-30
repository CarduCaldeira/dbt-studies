WITH
fct AS (
    SELECT listing_id, review_date
    FROM
        {{ ref('fct_reviews') }}
),
dim_listings AS (
    SELECT listing_id, created_at
    FROM {{ ref('dim_listings_cleansed') }}
)

SELECT *
FROM dim_listings
INNER JOIN  fct ON fct.listing_id = dim_listings.listing_id
WHERE dim_listings.created_at >= fct.review_date