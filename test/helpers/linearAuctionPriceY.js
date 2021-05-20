const linearAuctionPriceY = (y1, x) => {
    EPOCH_PERIOD = 28800;
    return (EPOCH_PERIOD + (y1 - 1)*(EPOCH_PERIOD - x)) / EPOCH_PERIOD;
};

module.exports = linearAuctionPriceY;
