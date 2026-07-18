<?php

declare (strict_types=1);
namespace OCA\Notifications\Vendor\Jose\Component\Encryption\Algorithm\KeyEncryption;

use OCA\Notifications\Vendor\Jose\Component\Encryption\Algorithm\KeyEncryption\Util\RSACrypt;
use Override;
final readonly class RSA15 extends RSA
{
    #[Override]
    public function name(): string
    {
        return 'RSA1_5';
    }
    #[Override]
    protected function getEncryptionMode(): int
    {
        return RSACrypt::ENCRYPTION_PKCS1;
    }
    #[Override]
    protected function getHashAlgorithm(): ?string
    {
        return null;
    }
}